# MobileCLIP zero-shot assets

The app bundles `AuraFit/Resources/MobileCLIPImageEncoder.mlpackage` (MobileCLIP-S0
image encoder, from Apple's official Core ML release at
https://huggingface.co/apple/coreml-mobileclip) and
`AuraFit/Resources/CLIPLabelEmbeddings.json` (precomputed text embeddings for the
persona and garment labels). `CLIPZeroShotClassifier` compares the on-device image
embedding against these label embeddings by cosine similarity.

## Regenerating `CLIPLabelEmbeddings.json`

Needed whenever prompts/labels change in `tokenize_prompts.py`, or if the encoder
model variant changes (image and text encoders must come from the same variant).

1. Download the matching **text** encoder and the CLIP BPE vocabulary:
   - `mobileclip_s0_text.mlpackage` from https://huggingface.co/apple/coreml-mobileclip
   - `bpe_simple_vocab_16e6.txt.gz` from https://github.com/openai/CLIP/tree/main/clip
2. Tokenize the prompts (pure Python, no dependencies):

   ```bash
   python3 tokenize_prompts.py   # writes tokens.json
   ```

3. Encode the prompts on macOS and build the asset:

   ```bash
   swift cliptool.swift mobileclip_s0_image.mlpackage mobileclip_s0_text.mlpackage \
       tokens.json LabelEmbeddings.json
   cp LabelEmbeddings.json ../../AuraFit/Resources/CLIPLabelEmbeddings.json
   ```

4. Spot-check rankings against sample photos:

   ```bash
   swift clipverify.swift mobileclip_s0_image.mlpackage LabelEmbeddings.json photo.jpg
   ```

`AuraFitTests/CLIPZeroShotClassifierTests` is the canary that both assets are
present in the app bundle and that classification is deterministic.

## Notes

- Embeddings are L2-normalized; multiple prompt templates per persona are averaged
  then re-normalized. Softmax temperature 100 (standard CLIP logit scale).
- MobileCLIP is released under Apple's model license — review its terms before
  commercial App Store distribution.
