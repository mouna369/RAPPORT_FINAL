// ====================================
// ABSTRACT — VERSION CORRIGÉE
// ====================================

#set par(justify: true)

= Abstract

#v(1cm)

#h(0.5cm)
This thesis presents the design and development of an intelligent customer sentiment analysis platform developed for Algérie Télécom as part of a final-year project conducted within the Information Systems Division. The main challenge lies in the difficulty of manually processing the large volumes of multilingual comments — Algerian Darija, Arabizi, and French — published daily by subscribers on social media platforms.

#h(0.5cm)
The proposed architecture is based on a distributed Big Data pipeline integrating Apache Kafka for real-time data ingestion, a Dockerized Apache Spark cluster for distributed parallel processing, and MongoDB as a NoSQL storage solution. A linguistic normalization module addresses the specific characteristics of the Algerian dialect, including code-switching, Arabizi transcription, and regional variations, using a unified dictionary and phonetic-graphic conversion rules.

#h(0.5cm)
Sentiment classification relies on DziriBERT, a Transformer-based model pre-trained on 1.1 million Algerian tweets and fine-tuned on a corpus of 24,046 annotated comments collected from Algérie Télécom’s social media pages. The integration of semantic features, TF-IDF vectorization, and class balancing techniques achieved an accuracy of 96.18% and a macro F1-score of 0.9617. A secondary classifier also identifies 12 categories of customer interactions, including network issues, billing, and customer support requests, with an accuracy of 77.3%.

#h(0.5cm)
The results are visualized through an interactive Plotly Dash dashboard operating in near real time. The platform also incorporates a two-level alert system, a conversational assistant powered by Groq LLaMA 3.3, and a recommendation engine designed to support operational decision-making. After a deduplication phase based on lexical similarity, the corpus was reduced from 26,576 to 24,046 exploitable comments.

*Keywords:* sentiment analysis, Algerian Darija, Algérie Télécom, DziriBERT, Big Data, Apache Spark, natural language processing, interactive dashboard, social media.

#pagebreak()