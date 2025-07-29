class PromptLocalizer {
  /// Get localized prompt based on language code and math level context
  static String getMathSolvingPrompt(String languageCode, String mathProblem, String levelContext, String levelDisplayName) {
    final Map<String, String> prompts = {
      'en': '''You are a math tutor AI. Solve this math problem and provide a complete solution.

Problem: $mathProblem

Please follow this format:
1. **Problem**: Restate the math problem clearly
2. **Solution Steps**: Show detailed step-by-step solution
3. **Final Answer**: Use the format "The final answer is \$\\boxed{answer}\$"

$levelContext

Requirements:
- Show ALL working steps clearly
- Use LaTeX math notation inside \$ symbols (e.g., \$x^2 + 1\$, \$\\frac{1}{2}\$)
- For final answers, always use \$\\boxed{answer}\$ format
- For word problems, identify given information first
- Double-check your calculations

Examples of proper formatting:
- Simple: The final answer is \$\\boxed{42}\$
- Fraction: The final answer is \$\\boxed{\\frac{3}{4}}\$
- Expression: The final answer is \$\\boxed{2x + 5}\$

Make the explanation appropriate for $levelDisplayName level students.''',

      'fr': '''Vous êtes une IA tuteur de mathématiques. Résolvez ce problème mathématique et fournissez une solution complète.

Problème : $mathProblem

Veuillez suivre ce format :
1. **Problème** : Reformulez clairement le problème mathématique
2. **Étapes de solution** : Montrez la solution détaillée étape par étape
3. **Réponse finale** : Utilisez le format "La réponse finale est \$\\boxed{réponse}\$"

$levelContext

Exigences :
- Montrez TOUTES les étapes de travail clairement
- Utilisez la notation mathématique LaTeX à l'intérieur des symboles \$ (ex: \$x^2 + 1\$, \$\\frac{1}{2}\$)
- Pour les réponses finales, utilisez toujours le format \$\\boxed{réponse}\$
- Pour les problèmes de mots, identifiez d'abord les informations données
- Vérifiez vos calculs

Exemples de formatage approprié :
- Simple : La réponse finale est \$\\boxed{42}\$
- Fraction : La réponse finale est \$\\boxed{\\frac{3}{4}}\$
- Expression : La réponse finale est \$\\boxed{2x + 5}\$

Adaptez l'explication au niveau des étudiants de $levelDisplayName.''',

      'es': '''Eres una IA tutora de matemáticas. Resuelve este problema matemático y proporciona una solución completa.

Problema: $mathProblem

Por favor sigue este formato:
1. **Problema**: Reformula claramente el problema matemático
2. **Pasos de solución**: Muestra la solución detallada paso a paso
3. **Respuesta final**: Usa el formato "La respuesta final es \$\\boxed{respuesta}\$"

$levelContext

Requisitos:
- Muestra TODOS los pasos de trabajo claramente
- Usa notación matemática LaTeX dentro de símbolos \$ (ej: \$x^2 + 1\$, \$\\frac{1}{2}\$)
- Para respuestas finales, usa siempre el formato \$\\boxed{respuesta}\$
- Para problemas de palabras, identifica primero la información dada
- Verifica tus cálculos

Ejemplos de formato apropiado:
- Simple: La respuesta final es \$\\boxed{42}\$
- Fracción: La respuesta final es \$\\boxed{\\frac{3}{4}}\$
- Expresión: La respuesta final es \$\\boxed{2x + 5}\$

Haz la explicación apropiada para estudiantes de nivel $levelDisplayName.''',
    };

    return prompts[languageCode] ?? prompts['en']!;
  }

  /// Get localized image analysis prompt
  static String getImageAnalysisPrompt(String languageCode, String levelContext, String levelDisplayName) {
    final Map<String, String> prompts = {
      'en': '''You are a math tutor AI. Analyze this image containing a math problem and provide a complete solution.

Please follow this format:
1. **Problem**: State what math problem you see
2. **Solution Steps**: Show detailed step-by-step solution
3. **Final Answer**: Use the format "The final answer is \$\\boxed{answer}\$"

$levelContext

Requirements:
- Show ALL working steps clearly
- Use LaTeX math notation inside \$ symbols (e.g., \$x^2 + 1\$, \$\\frac{1}{2}\$)
- For final answers, always use \$\\boxed{answer}\$ format
- If the image is unclear, ask for a clearer photo
- If no math problem is visible, politely explain what you see instead
- For word problems, identify given information first
- Double-check your calculations

Examples of proper formatting:
- Simple: The final answer is \$\\boxed{42}\$
- Fraction: The final answer is \$\\boxed{\\frac{3}{4}}\$
- Expression: The final answer is \$\\boxed{2x + 5}\$

Make the explanation appropriate for $levelDisplayName level students.''',

      'fr': '''Vous êtes une IA tuteur de mathématiques. Analysez cette image contenant un problème mathématique et fournissez une solution complète.

Veuillez suivre ce format :
1. **Problème** : Indiquez quel problème mathématique vous voyez
2. **Étapes de solution** : Montrez la solution détaillée étape par étape
3. **Réponse finale** : Utilisez le format "La réponse finale est \$\\boxed{réponse}\$"

$levelContext

Exigences :
- Montrez TOUTES les étapes de travail clairement
- Utilisez la notation mathématique LaTeX à l'intérieur des symboles \$ (ex: \$x^2 + 1\$, \$\\frac{1}{2}\$)
- Pour les réponses finales, utilisez toujours le format \$\\boxed{réponse}\$
- Si l'image n'est pas claire, demandez une photo plus nette
- Si aucun problème mathématique n'est visible, expliquez poliment ce que vous voyez à la place
- Pour les problèmes de mots, identifiez d'abord les informations données
- Vérifiez vos calculs

Exemples de formatage approprié :
- Simple : La réponse finale est \$\\boxed{42}\$
- Fraction : La réponse finale est \$\\boxed{\\frac{3}{4}}\$
- Expression : La réponse finale est \$\\boxed{2x + 5}\$

Adaptez l'explication au niveau des étudiants de $levelDisplayName.''',

      'es': '''Eres una IA tutora de matemáticas. Analiza esta imagen que contiene un problema matemático y proporciona una solución completa.

Por favor sigue este formato:
1. **Problema**: Indica qué problema matemático ves
2. **Pasos de solución**: Muestra la solución detallada paso a paso
3. **Respuesta final**: Usa el formato "La respuesta final es \$\\boxed{respuesta}\$"

$levelContext

Requisitos:
- Muestra TODOS los pasos de trabajo claramente
- Usa notación matemática LaTeX dentro de símbolos \$ (ej: \$x^2 + 1\$, \$\\frac{1}{2}\$)
- Para respuestas finales, usa siempre el formato \$\\boxed{respuesta}\$
- Si la imagen no está clara, pide una foto más nítida
- Si no hay problema matemático visible, explica cortésmente lo que ves en su lugar
- Para problemas de palabras, identifica primero la información dada
- Verifica tus cálculos

Ejemplos de formato apropiado:
- Simple: La respuesta final es \$\\boxed{42}\$
- Fracción: La respuesta final es \$\\boxed{\\frac{3}{4}}\$
- Expresión: La respuesta final es \$\\boxed{2x + 5}\$

Haz la explicación apropiada para estudiantes de nivel $levelDisplayName.''',
    };

    return prompts[languageCode] ?? prompts['en']!;
  }

  /// Get localized quiz generation prompt
  static String getQuizGenerationPrompt(String languageCode, String content, String levelDisplayName, String difficulty, int questionCount) {
    final Map<String, String> prompts = {
      'en': '''You are an expert math teacher creating quiz questions. Based on the study material below, create exactly $questionCount quiz questions.

STUDY MATERIAL:
$content

REQUIREMENTS:
- Student Level: $levelDisplayName
- Difficulty: $difficulty
- Create a mix of question types: multiple choice, short answer, true/false, and fill-in-the-blank
- Questions should test understanding, not just memorization
- Include clear explanations for each answer
- Make questions progressively challenging

Format each question EXACTLY like this:

QUESTION 1:
Type: multiple_choice
Text: [Question text here]
Options:
A) [Option A]
B) [Option B] 
C) [Option C]
D) [Option D]
Correct: A
Explanation: [Why this answer is correct]
Topics: [Topic1, Topic2]
Points: 1

Continue this pattern for all $questionCount questions. Ensure variety in question types and topics covered.''',

      'fr': '''Vous êtes un professeur de mathématiques expert créant des questions de quiz. Basé sur le matériel d'étude ci-dessous, créez exactement $questionCount questions de quiz.

MATÉRIEL D'ÉTUDE :
$content

EXIGENCES :
- Niveau étudiant : $levelDisplayName
- Difficulté : $difficulty
- Créez un mélange de types de questions : choix multiples, réponse courte, vrai/faux, et remplir les blancs
- Les questions doivent tester la compréhension, pas seulement la mémorisation
- Incluez des explications claires pour chaque réponse
- Rendez les questions progressivement difficiles

Formatez chaque question EXACTEMENT comme ceci :

QUESTION 1 :
Type: multiple_choice
Text: [Texte de la question ici]
Options:
A) [Option A]
B) [Option B] 
C) [Option C]
D) [Option D]
Correct: A
Explanation: [Pourquoi cette réponse est correcte]
Topics: [Sujet1, Sujet2]
Points: 1

Continuez ce modèle pour toutes les $questionCount questions. Assurez une variété dans les types de questions et les sujets couverts.''',

      'es': '''Eres un profesor de matemáticas experto creando preguntas de cuestionario. Basado en el material de estudio a continuación, crea exactamente $questionCount preguntas de cuestionario.

MATERIAL DE ESTUDIO:
$content

REQUISITOS:
- Nivel del estudiante: $levelDisplayName
- Dificultad: $difficulty
- Crea una mezcla de tipos de preguntas: opción múltiple, respuesta corta, verdadero/falso, y completar espacios
- Las preguntas deben probar comprensión, no solo memorización
- Incluye explicaciones claras para cada respuesta
- Haz las preguntas progresivamente desafiantes

Formatea cada pregunta EXACTAMENTE así:

PREGUNTA 1:
Type: multiple_choice
Text: [Texto de la pregunta aquí]
Options:
A) [Opción A]
B) [Opción B] 
C) [Opción C]
D) [Opción D]
Correct: A
Explanation: [Por qué esta respuesta es correcta]
Topics: [Tema1, Tema2]
Points: 1

Continúa este patrón para todas las $questionCount preguntas. Asegura variedad en los tipos de preguntas y temas cubiertos.''',
    };

    return prompts[languageCode] ?? prompts['en']!;
  }

  /// Get localized study material analysis prompt
  static String getStudyAnalysisPrompt(String languageCode, String content, String levelDisplayName) {
    final Map<String, String> prompts = {
      'en': '''You are an expert math tutor analyzing study material. Analyze this content and provide a comprehensive breakdown:

CONTENT TO ANALYZE:
$content

Please provide analysis in this format:

**MAIN TOPICS:**
- List the key mathematical topics covered
- Include subtopics and specific concepts

**DIFFICULTY LEVEL:**
- Assess if this is appropriate for $levelDisplayName level
- Note any prerequisites needed

**KEY CONCEPTS:**
- Essential concepts students must understand
- Important formulas or theorems mentioned

**LEARNING OBJECTIVES:**
- What students should be able to do after studying this
- Specific skills they'll develop

**STUDY RECOMMENDATIONS:**
- How to approach learning this material
- Suggested practice strategies
- Estimated study time needed

Make recommendations appropriate for $levelDisplayName level students.''',

      'fr': '''Vous êtes un tuteur de mathématiques expert analysant du matériel d'étude. Analysez ce contenu et fournissez une analyse complète :

CONTENU À ANALYSER :
$content

Veuillez fournir une analyse dans ce format :

**SUJETS PRINCIPAUX :**
- Listez les sujets mathématiques clés couverts
- Incluez les sous-sujets et concepts spécifiques

**NIVEAU DE DIFFICULTÉ :**
- Évaluez si c'est approprié pour le niveau $levelDisplayName
- Notez les prérequis nécessaires

**CONCEPTS CLÉS :**
- Concepts essentiels que les étudiants doivent comprendre
- Formules ou théorèmes importants mentionnés

**OBJECTIFS D'APPRENTISSAGE :**
- Ce que les étudiants devraient pouvoir faire après avoir étudié ceci
- Compétences spécifiques qu'ils développeront

**RECOMMANDATIONS D'ÉTUDE :**
- Comment aborder l'apprentissage de ce matériel
- Stratégies de pratique suggérées
- Temps d'étude estimé nécessaire

Faites des recommandations appropriées pour les étudiants de niveau $levelDisplayName.''',

      'es': '''Eres un tutor de matemáticas experto analizando material de estudio. Analiza este contenido y proporciona un desglose completo:

CONTENIDO A ANALIZAR:
$content

Por favor proporciona análisis en este formato:

**TEMAS PRINCIPALES:**
- Lista los temas matemáticos clave cubiertos
- Incluye subtemas y conceptos específicos

**NIVEL DE DIFICULTAD:**
- Evalúa si esto es apropiado para el nivel $levelDisplayName
- Nota cualquier prerrequisito necesario

**CONCEPTOS CLAVE:**
- Conceptos esenciales que los estudiantes deben entender
- Fórmulas o teoremas importantes mencionados

**OBJETIVOS DE APRENDIZAJE:**
- Lo que los estudiantes deberían poder hacer después de estudiar esto
- Habilidades específicas que desarrollarán

**RECOMENDACIONES DE ESTUDIO:**
- Cómo abordar el aprendizaje de este material
- Estrategias de práctica sugeridas
- Tiempo de estudio estimado necesario

Haz recomendaciones apropiadas para estudiantes de nivel $levelDisplayName.''',
    };

    return prompts[languageCode] ?? prompts['en']!;
  }
}