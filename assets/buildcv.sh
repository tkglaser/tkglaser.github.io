#/bin/bash

pandoc --reference-docx=word-template.docx -o ThomasGlaserCV.docx -f markdown -t docx ThomasGlaserCV.md