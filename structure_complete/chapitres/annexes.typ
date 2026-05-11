// ====================================
// ANNEXES
// Fichier : chapitres/annexes.typ
// ====================================

#set par(justify: true)
= Annexes

== Annexe A : Résultats complémentaires

=== A.1 Modèles classiques — Baselines

==== A.1.1 Courbes précision-rappel (Precision-Recall)

#figure(
  grid(
    columns: 2,
    gutter: 1cm,
    image("../images/pr_curve_logistic_count.png", width: 7cm),
    image("../images/pr_curve_logistic_tfidf.png", width: 7cm),
    image("../images/pr_curve_naive_bayes_count.png", width: 7cm),
    image("../images/pr_curve_naive_bayes_tfidf.png", width: 7cm),
    image("../images/pr_curve_svm_count.png", width: 7cm),
    image("../images/pr_curve_svm_tfidf.png", width: 7cm),
  ),
  caption: [
    Courbes précision-rappel pour les six configurations de baselines.
    L’ordre de lecture suit une progression de gauche à droite puis de haut en bas.
  ],
) <annexe:pr_curves>

==== A.1.2 Courbes ROC (autres modèles)

#figure(
  grid(
    columns: 2,
    gutter: 1cm,
    image("../images/roc_logistic_count.png", width: 7cm),
    image("../images/roc_logistic_tfidf.png", width: 7cm),
    image("../images/roc_naive_bayes_count.png", width: 7cm),
    image("../images/roc_naive_bayes_tfidf.png", width: 7cm),
    image("../images/roc_svm_count.png", width: 7cm),
  ),
  caption: [
    Courbes ROC des modèles baselines autres que SVM TF‑IDF (traité dans le chapitre principal).
  ],
) <annexe:roc_others>

==== A.1.3 Heatmaps des rapports de classification

#figure(
  grid(
    columns: 2,
    gutter: 1cm,
    image("../images/class_report_logistic_count.png", width: 7cm),
    image("../images/class_report_logistic_tfidf.png", width: 7cm),
    image("../images/class_report_naive_bayes_count.png", width: 7cm),
    image("../images/class_report_naive_bayes_tfidf.png", width: 7cm),
    image("../images/class_report_svm_count.png", width: 7cm),
    image("../images/class_report_svm_tfidf.png", width: 7cm),
  ),
  caption: [
    Heatmaps des métriques (précision, rappel, F1‑score) par classe pour chaque baseline.
  ],
) <annexe:class_heatmaps>

==== A.1.4 Comparaison synthétique des métriques

#figure(
  image("../images/metric_comparison.png", width: 12cm),
  caption: [
    Comparaison visuelle de l’Accuracy, du F1‑macro et du F1‑weighted pour l’ensemble des modèles baselines.
  ],
) <annexe:metric_comp>

=== A.2 Modèles avancés — XGBoost, LightGBM, SVM RBF

Les graphiques ci-dessous sont issus des expérimentations menées avec les modèles avancés (XGBoost, LightGBM, SVM à noyau RBF). Les résultats détaillés sont commentés dans le chapitre 5.

==== A.2.1 Courbes ROC

#figure(
  grid(
    columns: 2,
    gutter: 1cm,
    image("../images/advanced_roc_xgboost.png", width: 7cm),
    image("../images/advanced_roc_lightgbm.png", width: 7cm),
    image("../images/advanced_roc_svm_rbf.png", width: 7cm),
  ),
  caption: [
    Courbes ROC pour les trois modèles avancés.
    *De gauche à droite* : XGBoost, LightGBM, SVM RBF.
  ],
) <annexe:advanced_roc>

==== A.2.2 Courbes précision-rappel

#figure(
  grid(
    columns: 2,
    gutter: 1cm,
    image("../images/advanced_pr_xgboost.png", width: 7cm),
    image("../images/advanced_pr_lightgbm.png", width: 7cm),
    image("../images/advanced_pr_svm_rbf.png", width: 7cm),
  ),
  caption: [
    Courbes précision‑rappel pour les modèles avancés.
  ],
) <annexe:advanced_pr>

==== A.2.3 Heatmaps des rapports de classification

#figure(
  grid(
    columns: 2,
    gutter: 1cm,
    image("../images/advanced_class_report_xgboost.png", width: 7cm),
    image("../images/advanced_class_report_lightgbm.png", width: 7cm),
    image("../images/advanced_class_report_svm_rbf.png", width: 7cm),
  ),
  caption: [
    Heatmaps des métriques par classe (précision, rappel, F1‑score) pour chaque modèle avancé.
  ],
) <annexe:advanced_class_heatmaps>

==== A.2.4 Temps d’entraînement

#figure(
  image("../images/advanced_training_time.png", width: 12cm),
  caption: [
    Temps d’entraînement (GridSearch 3 plis inclus) des modèles avancés.
  ],
) <annexe:advanced_training_time>

=== A.3 Optimisation Avancée et Architecture Hybride DziriBERT

Matrices de confusion de l'Experience de base :

#figure(
  image("../images/matrice_confusion_experience_base.jpg", width: 13cm),
  caption: [Matrices de confusion de Experience de base.],
) <matrice_confusion_experiece_base>

\

Matrices de confusion de l'Experience 1 :

#figure(
  image("../images/matrice_confusion_exp1.jpg", width: 13cm),
  caption: [Matrices de confusion de Experience 1.],
) <matrice_confusion_experiece1>

Matrices de confusion de l'Experience 2 :

#figure(
  image("../images/matrice_confusion_exp2.jpg", width: 13cm),
  caption: [Matrices de confusion de Experience 2.],
) <matrice_confusion_experiece2>

Matrices de confusion de l'Experience 3 :

#figure(
  image("../images/matrice_confusion_exp3.jpg", width: 13cm),
  caption: [Matrices de confusion de Experience 3.],
) <matrice_confusion_experiece3>

Matrices de confusion de l'Experience 4 :

#figure(
  image("../images/matrice_confusion_exp4.jpg", width: 13cm),
  caption: [Matrices de confusion de Experience 4.],
) <matrice_confusion_experiece4>


Matrices de confusion de l'Experience 5 :

#figure(
  image("../images/matrice_confusion_exp5.jpg", width: 13cm),
  caption: [Matrices de confusion de Experience 5.],
) <matrice_confusion_experiece5>


=== A.4 Évaluation sur un test standard

Un ensemble de 14 commentaires représentatifs (non vus lors de l’entraînement)
a été annoté manuellement. Le détecteur obtient **14/14, soit 100 %** de
bonnes classifications. La table en donne quelques exemples.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    inset: (x: 5pt, y: 4pt),
    align: (left, left, left, left),
    stroke: 0.5pt,
    [*Commentaire (extrait)*], [*Langue attendue*], [*Langue détectée*], [*Confiance*],
    ["خدمات جد فاشلة ولا تلبي الحد الأدنى"], [arabe classique], [arabe classique], [46 %],
    ["أروحوا أربطوا منبعد حكوا على إستفادة..."], [darija], [darija], [99 %],
    ["Tlgona cnx mchi 39lya hadi 3liha g3dto..."], [arabizi], [arabizi], [95 %],
    ["service vraiment nul depuis 3 jours"], [français], [français], [64 %],
    ["very bad network please fix it"], [anglais], [anglais], [44 %],
    ["أعطونا حل بعد الفتح تخرجلي inactive..."], [mixte], [mixte], [63 %],
  ),
  caption: [Résultats du détecteur sur six exemples représentatifs (sur les 14 du test).]
) <lang_test>

La confiance peut être modérée (46 % pour le premier exemple) en raison de la
brièveté du texte, mais toutes les prédictions restent correctes.

// === A.5 Classification des motifs (reason) et des thèmes

// Les figures ci‑dessous complètent l’analyse du chapitre 5 concernant la classification fine des motifs d’insatisfaction et leur agrégation en thèmes métier.

// ==== A.5.1 Matrice de confusion des 12 motifs

// La prédiction des motifs (*reason*) par DziriBERT atteint une accuracy de 78,0 %. La matrice de confusion ci‑dessous montre que les principales confusions se situent entre `probleme_technique` et `autre` (descriptions trop courtes ou ambiguës), ainsi qu’entre `absence_service` et `autre`.

// // #figure(
// //   image("../images/reason_confusion_matrix.png", width: 13cm),
// //   caption: [
// //     Matrice de confusion de la classification des 12 motifs (*reason*) par DziriBERT.
// //     Les classes sont ordonnées selon le même ordre que dans le tableau @tab:reason_results.
// //   ],
// // ) <annexe:reason_cm>

// ==== A.5.2 Distribution des thèmes

// En appliquant le mapping thème → motifs (voir tableau @tab:themes) aux prédictions du modèle, on obtient la répartition suivante des 9 thèmes dans le corpus complet (13 677 commentaires).

// #figure(
//   image("../images/themes_distribution.png", width: 12cm),
//   caption: [
//     Distribution des 9 thèmes. Les thèmes `experience_positive`, `information_generale` et `reseau_technique` concentrent plus de la moitié des commentaires.
//   ],
// ) <annexe:themes_dist>

// L’ensemble des artefacts (modèle sauvegardé, mapping, script d’inférence) est disponible dans l’archive `package_reason_theme.zip` fournie avec les ressources du chapitre.