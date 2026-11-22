# ARETINA: Mobile-Based Early Eye Disease Detection

Flutter app for early eye-disease screening. It classifies an eye image
as normal, cataract, or conjunctivitis using an on-device
TensorFlow Lite model.

> For screening and educational purposes only. Not a medical diagnosis.

## Results (MobileNetV2, Keras)
| Metric | Score |
|--------|-------|
| Accuracy | 97.84% |
| Precision | 97.89% |
| Recall | 97.84% |
| F1-score | 97.83% |

Evaluated on [test set / validation set, pastikan] ([N] images).

## Dataset
| Class | Images |
|-------|--------|
| Normal | 1,002 |
| Cataract | 848 |
| Conjunctivitis | 462 |
| **Total** | **2,312** |

Public datasets:
[Mendeley Data](https://data.mendeley.com/datasets/n9zp473wfw/2),
[Kaggle](https://www.kaggle.com/datasets/nandanp6/cataract-image-dataset)

## Model pipeline
Dataset preparation → MobileNetV2 training and evaluation (Keras)
→ conversion to TensorFlow Lite → integration into the Flutter app.
The model runs fully on-device (no internet required).

## Features
- [Ambil foto / pilih dari galeri]
- [Hasil klasifikasi + confidence]
- [Fitur lain yang benar-benar ada]

## Tech
Flutter, Dart, Python, Keras/TensorFlow, MobileNetV2, TensorFlow Lite

## How to run
```bash
git clone https://github.com/Zaharaaz/[nama-repo]
cd [nama-repo]
flutter pub get
flutter run
```

## Demo
![app screenshot](A_1.png)
![app screenshot](A_2.png)
![app screenshot](A_3.png)
