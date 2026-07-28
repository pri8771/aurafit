"""Tokenizes label prompts with the CLIP BPE tokenizer (pure Python port of
openai/CLIP simple_tokenizer, minus ftfy — prompts here are plain ASCII).

Outputs tokens.json: {"context_length": 77, "labels": [{"group", "label", "prompt", "tokens"}]}
"""
import gzip, html, json, re

VOCAB_PATH = "bpe_simple_vocab_16e6.txt.gz"
CONTEXT_LENGTH = 77


def bytes_to_unicode():
    bs = list(range(ord("!"), ord("~") + 1)) + list(range(ord("\xa1"), ord("\xac") + 1)) + list(range(ord("\xae"), ord("\xff") + 1))
    cs = bs[:]
    n = 0
    for b in range(2**8):
        if b not in bs:
            bs.append(b)
            cs.append(2**8 + n)
            n += 1
    return dict(zip(bs, [chr(c) for c in cs]))


def get_pairs(word):
    pairs = set()
    prev = word[0]
    for ch in word[1:]:
        pairs.add((prev, ch))
        prev = ch
    return pairs


class SimpleTokenizer:
    def __init__(self, bpe_path=VOCAB_PATH):
        self.byte_encoder = bytes_to_unicode()
        merges = gzip.open(bpe_path).read().decode("utf-8").split("\n")
        merges = merges[1 : 49152 - 256 - 2 + 1]
        merges = [tuple(m.split()) for m in merges]
        vocab = list(bytes_to_unicode().values())
        vocab = vocab + [v + "</w>" for v in vocab]
        for merge in merges:
            vocab.append("".join(merge))
        vocab.extend(["<|startoftext|>", "<|endoftext|>"])
        self.encoder = dict(zip(vocab, range(len(vocab))))
        self.bpe_ranks = dict(zip(merges, range(len(merges))))
        self.cache = {"<|startoftext|>": "<|startoftext|>", "<|endoftext|>": "<|endoftext|>"}
        self.pat = re.compile(
            r"""<\|startoftext\|>|<\|endoftext\|>|'s|'t|'re|'ve|'m|'ll|'d|[a-zA-Z]+|[0-9]|[^\sa-zA-Z0-9]+""",
            re.IGNORECASE,
        )

    def bpe(self, token):
        if token in self.cache:
            return self.cache[token]
        word = tuple(token[:-1]) + (token[-1] + "</w>",)
        pairs = get_pairs(word)
        if not pairs:
            return token + "</w>"
        while True:
            bigram = min(pairs, key=lambda pair: self.bpe_ranks.get(pair, float("inf")))
            if bigram not in self.bpe_ranks:
                break
            first, second = bigram
            new_word = []
            i = 0
            while i < len(word):
                try:
                    j = word.index(first, i)
                    new_word.extend(word[i:j])
                    i = j
                except ValueError:
                    new_word.extend(word[i:])
                    break
                if word[i] == first and i < len(word) - 1 and word[i + 1] == second:
                    new_word.append(first + second)
                    i += 2
                else:
                    new_word.append(word[i])
                    i += 1
            word = tuple(new_word)
            if len(word) == 1:
                break
            pairs = get_pairs(word)
        word = " ".join(word)
        self.cache[token] = word
        return word

    def encode(self, text):
        bpe_tokens = []
        text = html.unescape(html.unescape(text))
        text = re.sub(r"\s+", " ", text).strip().lower()
        for token in re.findall(self.pat, text):
            token = "".join(self.byte_encoder[b] for b in token.encode("utf-8"))
            bpe_tokens.extend(self.encoder[bpe_token] for bpe_token in self.bpe(token).split(" "))
        return bpe_tokens


# ---- Label definitions -------------------------------------------------------

# Generic templates combined with per-persona descriptors. CLIP zero-shot accuracy
# improves with prompt ensembling (the CLIP paper averaged 80 templates); each persona
# ends up with len(TEMPLATES) + its handwritten extras.
TEMPLATES = [
    "a full-body photo of a person wearing {}",
    "a photo of someone dressed in {}",
    "an outfit-of-the-day photo showing {}",
    "a street style photograph of a person in {}",
    "a fashion photo of {}",
    "a mirror selfie of a person wearing {}",
    "a snapshot of somebody wearing {}",
]

PERSONA_DESCRIPTORS = {
    "Streetwear": "a streetwear outfit with baggy urban pieces",
    "Soft Luxury": "an elegant quiet luxury outfit in refined neutral tones",
    "Minimalist": "a minimalist outfit of simple clean basics in plain solid colors",
    "Sporty": "athletic sportswear or activewear",
    "Classic": "classic tailored formal clothing",
    "Bold & Expressive": "a bold colorful statement outfit with striking patterns",
    "Cozy": "a cozy comfortable outfit of soft knitwear and relaxed layers",
}

PERSONA_EXTRAS = {
    "Streetwear": [
        "someone wearing a hoodie, cargo pants and sneakers, street fashion",
        "a person in oversized urban skate style clothing",
    ],
    "Soft Luxury": [
        "someone wearing silk, cashmere and tailored cream tones, old money style",
        "a person in understated designer clothing with luxurious textures",
    ],
    "Minimalist": [
        "someone wearing plain monochrome basics with clean lines, capsule wardrobe",
        "a person in a simple white tee and straight trousers, minimal style",
    ],
    "Sporty": [
        "someone wearing a tracksuit, leggings or gym gear ready to work out",
        "a person in running shoes, shorts and an athletic top",
    ],
    "Classic": [
        "someone wearing a suit, blazer or crisp shirt, timeless business attire",
        "a person in preppy smart-casual tailoring",
    ],
    "Bold & Expressive": [
        "someone wearing loud clashing prints and vivid saturated colors",
        "a person in avant-garde expressive fashion that stands out",
    ],
    "Cozy": [
        "someone wearing a chunky sweater, fleece or soft loungewear",
        "a person bundled in warm comfortable layers at home",
    ],
}

PERSONA_PROMPTS = {
    persona: [t.format(desc) for t in TEMPLATES] + PERSONA_EXTRAS[persona]
    for persona, desc in PERSONA_DESCRIPTORS.items()
}

# Frame-level capture problems, plus a positive anchor ("good photo"). Evaluated as one
# softmax group by `CLIPZeroShotClassifier.assessPhotoIssues`; the anchor keeps ordinary
# photos from being force-assigned an issue. The issue label strings are a contract with
# `PhotoCoach` in the app — change them together.
PHOTO_ISSUE_PROMPTS = {
    "good photo": [
        "a sharp well-lit photo of a person showing their full body",
        "a clear high quality full-length photo of someone standing",
    ],
    "blurry": [
        "a blurry out of focus photo",
        "a motion-blurred shaky photograph",
    ],
    "too dark": [
        "a very dark underexposed photo taken in low light",
        "a dim shadowy photo where details are hard to see",
    ],
    "overexposed": [
        "an overexposed washed out photo with blown highlights",
        "a photo ruined by harsh bright glare",
    ],
    "no person": [
        "a photo of a room, scene or objects with no people in it",
        "an empty landscape photo with nobody present",
    ],
    "face only": [
        "a close-up selfie showing only a face",
        "a head and shoulders portrait photo cropped above the chest",
    ],
}

GARMENTS = [
    "hoodie", "t-shirt", "dress shirt", "blouse", "suit", "blazer", "dress",
    "skirt", "jeans", "denim jacket", "leather jacket", "puffer jacket",
    "coat", "trench coat", "sweater", "cardigan", "tank top", "sweatpants",
    "cargo pants", "trousers", "shorts", "leggings", "sneakers", "boots",
    "high heels", "cap or beanie",
]
GARMENT_TEMPLATE = "a person wearing a {}"

if __name__ == "__main__":
    tok = SimpleTokenizer()
    sot = tok.encoder["<|startoftext|>"]
    eot = tok.encoder["<|endoftext|>"]
    out = {"context_length": CONTEXT_LENGTH, "labels": []}

    def add(group, label, prompt):
        ids = [sot] + tok.encode(prompt) + [eot]
        assert len(ids) <= CONTEXT_LENGTH, prompt
        ids = ids + [0] * (CONTEXT_LENGTH - len(ids))
        out["labels"].append({"group": group, "label": label, "prompt": prompt, "tokens": ids})

    for persona, prompts in PERSONA_PROMPTS.items():
        for p in prompts:
            add("persona", persona, p)
    for g in GARMENTS:
        add("garment", g, GARMENT_TEMPLATE.format(g))
    for issue, prompts in PHOTO_ISSUE_PROMPTS.items():
        for p in prompts:
            add("photoIssue", issue, p)

    with open("tokens.json", "w") as f:
        json.dump(out, f)
    print(f"Wrote {len(out['labels'])} tokenized prompts to tokens.json")
