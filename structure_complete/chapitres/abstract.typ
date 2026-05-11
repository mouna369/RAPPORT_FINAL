// ====================================
// ABSTRACT
// Fichier : chapitres/abstract.typ
// ====================================

#set par(justify: true)
= Abstract


#h(0.5cm)This thesis presents the design and implementation of an intelligent customer sentiment analysis platform developed for Algérie Télécom as part of a final-year project conducted within the Information Systems Division. The central challenge lies in the impossibility of manually processing the multilingual comment streams Algerian Darija, Arabizi, French generated daily on social media by the operator's subscribers.

#h(0.5cm)The proposed architecture relies on a distributed Big Data pipeline: Apache Kafka handles streaming ingestion, a Dockerized Apache Spark cluster (1 master, 3 workers) ensures parallel processing, and MongoDB serves as the NoSQL storage layer. A linguistic normalization module addresses the specificities of the Algerian dialect code-switching, Arabizi transcription, regional variations through a unified dictionary and phonético-graphic conversion rules.

#h(0.5cm)Sentiment classification is performed by DziriBERT, a Transformer model pre-trained on 1.1 million Algerian tweets, fine-tuned on a corpus of 24,046 annotated comments collected from Algérie Télécom's social media pages. The integration of semantic flags, 150-dimension TF-IDF vectorization, and class rebalancing yields an accuracy of 96.18% and a macro F1-score of 0.9617 surpassing the 85% target set in the project specifications. A secondary classifier identifies 12 interaction motifs (network issues, billing, customer service, etc.) with an accuracy of 77.3%.

#h(0.5cm)Results are delivered through a Plotly Dash interactive dashboard in near-real time, featuring a two-tier alert system, a conversational assistant powered by Groq LLaMA 3.3 with cosine similarity-based retrieval-augmented generation, and a business recommendation engine. The full corpus, reduced from 26,576 to 24,046 documents through Jaccard-Words deduplication, is indexed across 51 structured fields.

*Keywords:* sentiment analysis, Algerian Darija, Algérie Télécom, DziriBERT, Big Data, Apache Spark, NLP, interactive dashboard, social media.


#pagebreak()
