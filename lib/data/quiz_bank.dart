import 'course_models.dart';

class _QuizConcept {
  const _QuizConcept(this.topic, this.term, this.definition);

  final String topic;
  final String term;
  final String definition;
}

_QuizConcept _c(String topic, String term, String definition) =>
    _QuizConcept(topic, term, definition);

final quizBankSubjects = _conceptsBySubject.keys.toList(growable: false);

final expandedQuizQuestions = [
  for (final entry in _conceptsBySubject.entries)
    for (
      var conceptIndex = 0;
      conceptIndex < entry.value.length;
      conceptIndex++
    )
      for (var variation = 0; variation < 15; variation++)
        _buildQuestion(entry.key, entry.value, conceptIndex, variation),
];

QuizQuestion _buildQuestion(
  String subject,
  List<_QuizConcept> concepts,
  int conceptIndex,
  int variation,
) {
  final concept = concepts[conceptIndex];
  final difficulty = switch (variation ~/ 5) {
    0 => 'Basic',
    1 => 'Intermediate',
    _ => 'Advanced',
  };
  final questionAsksForDefinition = variation < 5;
  final prompt = switch (variation) {
    0 => 'Which description best defines ${concept.term} in $subject?',
    1 => 'What is the primary purpose of ${concept.term}?',
    2 =>
      'In ${concept.topic}, which statement about ${concept.term} is accurate?',
    3 => 'A learner encounters ${concept.term}. How should it be understood?',
    4 => 'Which explanation should be associated with ${concept.term}?',
    5 =>
      'A $subject task needs this behavior: ${concept.definition} Which concept fits?',
    6 =>
      'A practical ${concept.topic} problem calls for: ${concept.definition} Which concept applies?',
    7 =>
      'Which $subject concept provides this capability: ${concept.definition}',
    8 =>
      'A team requires the following in ${concept.topic}: ${concept.definition} What should it use?',
    9 =>
      'Which concept is the best match for this requirement: ${concept.definition}',
    10 => 'Which $subject concept is described by: ${concept.definition}',
    11 =>
      'Identify the ${concept.topic} concept from this description: ${concept.definition}',
    12 =>
      'A reviewer reads: "${concept.definition}" Which concept are they reviewing?',
    13 => 'Which term names this $subject behavior: ${concept.definition}',
    _ => 'Select the concept whose defining property is: ${concept.definition}',
  };
  final relatedIndexes = [
    conceptIndex,
    (conceptIndex + 1) % concepts.length,
    (conceptIndex + 4) % concepts.length,
    (conceptIndex + 7) % concepts.length,
  ];
  final choices = relatedIndexes
      .map(
        (index) => questionAsksForDefinition
            ? concepts[index].definition
            : concepts[index].term,
      )
      .toList();
  final rotation = variation % choices.length;
  final options = [
    for (var index = 0; index < choices.length; index++)
      choices[(index + rotation) % choices.length],
  ];
  final correctIndex = (choices.length - rotation) % choices.length;

  return QuizQuestion(
    id: 'bank-${_slug(subject)}-$conceptIndex-$variation',
    subject: subject,
    topic: concept.topic,
    prompt: prompt,
    options: options,
    answerIndex: correctIndex,
    difficulty: difficulty,
    explanation:
        '${concept.term} is ${concept.definition} This is useful in ${concept.topic}; '
        'choose it when the task needs this behavior rather than a neighboring concept.',
  );
}

String _slug(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

final _conceptsBySubject = <String, List<_QuizConcept>>{
  'Python': [
    _c(
      'Execution',
      'the Python interpreter',
      'executes Python source code and reports its result or runtime errors.',
    ),
    _c(
      'Environments',
      'a virtual environment',
      'isolates a project’s installed packages from other Python projects.',
    ),
    _c(
      'Collections',
      'a list',
      'stores an ordered, mutable sequence that can contain repeated values.',
    ),
    _c(
      'Collections',
      'a tuple',
      'stores an ordered sequence whose structure cannot be changed after creation.',
    ),
    _c(
      'Collections',
      'a set',
      'stores distinct hashable values and supports membership operations.',
    ),
    _c(
      'Collections',
      'a dictionary',
      'maps unique hashable keys to values for lookup by key.',
    ),
    _c(
      'Comprehensions',
      'a list comprehension',
      'creates a list by applying an expression to items selected by an iterable and optional condition.',
    ),
    _c(
      'Iteration',
      'a generator',
      'produces values lazily one at a time instead of materializing the full sequence.',
    ),
    _c(
      'Functions',
      'a decorator',
      'wraps or modifies a callable’s behavior without rewriting the callable’s body.',
    ),
    _c(
      'Resource management',
      'a context manager',
      'acquires a resource and reliably performs cleanup when its managed block exits.',
    ),
  ],
  'SQL': [
    _c(
      'Queries',
      'projection',
      'chooses which columns a query returns, commonly through its SELECT list.',
    ),
    _c(
      'Queries',
      'row filtering',
      'uses a WHERE predicate to exclude rows before grouping and aggregation.',
    ),
    _c(
      'Relationships',
      'an inner join',
      'returns combinations of rows that satisfy the join condition on both sides.',
    ),
    _c(
      'Aggregation',
      'GROUP BY',
      'forms groups of rows so aggregate expressions can calculate one result per group.',
    ),
    _c(
      'Aggregation',
      'HAVING',
      'filters groups after aggregation has been computed.',
    ),
    _c(
      'Constraints',
      'a primary key',
      'uniquely identifies each row and disallows duplicate or null key values.',
    ),
    _c(
      'Constraints',
      'a foreign key',
      'constrains references so related values correspond to a key in another or the same table.',
    ),
    _c(
      'Transactions',
      'transaction atomicity',
      'ensures a transaction’s operations are committed together or rolled back together.',
    ),
    _c(
      'Performance',
      'a database index',
      'maintains a search structure that can speed selected lookups at storage and write cost.',
    ),
    _c(
      'Analytics',
      'a window function',
      'calculates across related rows while retaining each input row in the result.',
    ),
  ],
  'Machine Learning': [
    _c(
      'Evaluation',
      'a training set',
      'fits model parameters using examples available to the learning algorithm.',
    ),
    _c(
      'Evaluation',
      'a validation set',
      'supports model selection and tuning without being used as the final unbiased estimate.',
    ),
    _c(
      'Evaluation',
      'a held-out test set',
      'estimates final generalization after model and parameter choices are complete.',
    ),
    _c(
      'Generalization',
      'overfitting',
      'occurs when a model fits training-specific noise and performs worse on unseen examples.',
    ),
    _c(
      'Generalization',
      'regularization',
      'penalizes model complexity to discourage fitting noise and improve generalization.',
    ),
    _c(
      'Metrics',
      'precision',
      'is the fraction of predicted positive cases that are truly positive.',
    ),
    _c(
      'Metrics',
      'recall',
      'is the fraction of actual positive cases that are successfully detected.',
    ),
    _c(
      'Validation',
      'cross-validation',
      'repeats training and evaluation across folds to estimate performance more robustly.',
    ),
    _c(
      'Data preparation',
      'data leakage',
      'occurs when training or evaluation uses information unavailable at prediction time.',
    ),
    _c(
      'Data preparation',
      'feature scaling',
      'transforms numeric feature ranges to support algorithms sensitive to magnitude.',
    ),
  ],
  'Data Science': [
    _c(
      'Exploration',
      'exploratory data analysis',
      'uses summaries and visualizations to understand distributions, relationships, and data quality.',
    ),
    _c(
      'Data quality',
      'missingness analysis',
      'investigates why values are absent before choosing deletion or imputation.',
    ),
    _c(
      'Statistics',
      'the median',
      'is the middle ordered observation and is relatively resistant to extreme values.',
    ),
    _c(
      'Statistics',
      'standard deviation',
      'summarizes the typical spread of observations around their mean.',
    ),
    _c(
      'Relationships',
      'correlation',
      'measures association and alone does not establish a causal relationship.',
    ),
    _c(
      'Study design',
      'sampling bias',
      'occurs when the selection process makes the observed sample unrepresentative of the target population.',
    ),
    _c(
      'Study design',
      'confounding',
      'occurs when a third factor influences both an exposure and an observed outcome.',
    ),
    _c(
      'Communication',
      'a confidence interval',
      'expresses uncertainty around an estimate under the assumptions of its statistical procedure.',
    ),
    _c(
      'Reproducibility',
      'a reproducible analysis',
      'records data, transformations, assumptions, and code so another run can be audited.',
    ),
    _c(
      'Communication',
      'a data visualization',
      'encodes data visually to help readers compare patterns and identify relevant variation.',
    ),
  ],
  'Artificial Intelligence': [
    _c(
      'Search',
      'a state',
      'represents a possible configuration of a problem that an agent can reason about.',
    ),
    _c(
      'Search',
      'an action',
      'transitions a problem from one state to a successor state.',
    ),
    _c(
      'Search',
      'an admissible heuristic',
      'never overestimates the remaining cost to a goal and can preserve optimality in A-star search.',
    ),
    _c(
      'Game search',
      'minimax',
      'selects a move by reasoning about alternating decisions by a maximizing and minimizing player.',
    ),
    _c(
      'Knowledge representation',
      'a knowledge graph',
      'represents entities and their relationships as connected, queryable facts.',
    ),
    _c(
      'Planning',
      'a planning problem',
      'specifies an initial state, actions, goals, and constraints for finding a valid action sequence.',
    ),
    _c(
      'Expert systems',
      'an inference engine',
      'applies rules to known facts to derive conclusions in a rule-based system.',
    ),
    _c(
      'Learning agents',
      'a reward signal',
      'provides feedback about outcomes that guides an agent’s policy learning.',
    ),
    _c(
      'Responsible AI',
      'fairness evaluation',
      'checks for unjustified performance or impact differences across relevant groups.',
    ),
    _c(
      'Evaluation',
      'a representative test set',
      'reflects intended users and conditions so system failures can be measured meaningfully.',
    ),
  ],
  'Data Structures and Algorithms': [
    _c(
      'Sequences',
      'an array',
      'stores indexed elements in contiguous storage and supports constant-time indexed access.',
    ),
    _c(
      'Sequences',
      'a linked list',
      'stores nodes connected by references and can insert locally without shifting an array.',
    ),
    _c(
      'Abstract data types',
      'a stack',
      'supports last-in, first-out access through push and pop operations.',
    ),
    _c(
      'Abstract data types',
      'a queue',
      'supports first-in, first-out access through enqueue and dequeue operations.',
    ),
    _c(
      'Lookup',
      'a hash table',
      'maps keys to buckets for expected constant-time lookup under suitable hashing assumptions.',
    ),
    _c(
      'Trees',
      'a binary search tree',
      'orders keys so left-subtree values precede a node and right-subtree values follow it.',
    ),
    _c(
      'Priority queues',
      'a heap',
      'keeps the minimum or maximum element at its root for efficient priority access.',
    ),
    _c(
      'Graphs',
      'breadth-first search',
      'explores a graph in layers and finds shortest paths in an unweighted graph.',
    ),
    _c(
      'Searching',
      'binary search',
      'finds a target in sorted data by repeatedly discarding half of the remaining range.',
    ),
    _c(
      'Optimization',
      'dynamic programming',
      'reuses solutions to overlapping subproblems to avoid repeated computation.',
    ),
  ],
  'Java': [
    _c(
      'Types',
      'static typing',
      'checks declared types during compilation and rejects many invalid operations before execution.',
    ),
    _c(
      'Objects',
      'a constructor',
      'initializes a newly created object and shares the class name in Java.',
    ),
    _c(
      'Objects',
      'encapsulation',
      'controls access to object state through a deliberate public interface.',
    ),
    _c(
      'Inheritance',
      'method overriding',
      'provides a subclass implementation for an inherited instance method with a compatible signature.',
    ),
    _c(
      'Polymorphism',
      'dynamic dispatch',
      'chooses an overridden instance method based on the runtime object type.',
    ),
    _c(
      'Collections',
      'a HashMap',
      'stores key-value associations and uses hashing for expected efficient key lookup.',
    ),
    _c(
      'Generics',
      'a type parameter',
      'lets a class or method operate on typed values while retaining compile-time checks.',
    ),
    _c(
      'Exceptions',
      'a checked exception',
      'must be caught or declared by a method under Java’s checked-exception rules.',
    ),
    _c(
      'Concurrency',
      'synchronization',
      'coordinates access to shared mutable state to prevent unsafe concurrent updates.',
    ),
    _c(
      'Resources',
      'try-with-resources',
      'closes eligible resources automatically when the try block completes.',
    ),
  ],
  'C': [
    _c(
      'Compilation',
      'the preprocessor',
      'handles directives such as include and macro expansion before compilation proper.',
    ),
    _c(
      'Types',
      'a pointer',
      'stores an address and can refer indirectly to an object in memory.',
    ),
    _c(
      'Memory',
      'malloc',
      'requests a block of dynamically allocated memory whose contents are initially indeterminate.',
    ),
    _c(
      'Memory',
      'free',
      'releases a dynamically allocated block so it is no longer owned by the caller.',
    ),
    _c(
      'Arrays',
      'array indexing',
      'accesses an element using an offset from the first element of the array.',
    ),
    _c(
      'Functions',
      'a function prototype',
      'declares a function’s name and parameter types before its definition is used.',
    ),
    _c(
      'Structures',
      'a struct',
      'groups named members that may have different types into one C object.',
    ),
    _c(
      'Strings',
      'the null terminator',
      'marks the end of a conventional C string with a zero-valued character.',
    ),
    _c(
      'Files',
      'fclose',
      'flushes and closes a stream opened through the C standard I/O library.',
    ),
    _c(
      'Undefined behavior',
      'undefined behavior',
      'means the C standard imposes no requirements on the program’s result.',
    ),
  ],
  'C++': [
    _c(
      'Resources',
      'RAII',
      'ties resource lifetime to object lifetime so destruction releases the resource automatically.',
    ),
    _c(
      'Ownership',
      'std::unique_ptr',
      'expresses exclusive ownership and destroys its managed object when the pointer leaves scope.',
    ),
    _c(
      'Ownership',
      'std::shared_ptr',
      'shares ownership and destroys its object after the final owning reference is released.',
    ),
    _c(
      'Polymorphism',
      'a virtual function',
      'enables runtime dispatch to an overridden implementation through a base reference or pointer.',
    ),
    _c(
      'Generic programming',
      'a template',
      'defines type- or value-parameterized code that is instantiated for specific arguments.',
    ),
    _c(
      'Containers',
      'std::vector',
      'provides a dynamically sized contiguous sequence with indexed access.',
    ),
    _c(
      'Value semantics',
      'a move operation',
      'can transfer resources from an expiring object instead of copying them.',
    ),
    _c(
      'Exceptions',
      'stack unwinding',
      'destroys automatic objects as control exits scopes while propagating an exception.',
    ),
    _c(
      'Algorithms',
      'an iterator',
      'provides a common way to traverse elements in a container or range.',
    ),
    _c(
      'Concurrency',
      'std::mutex',
      'protects a critical section so only one thread at a time holds its lock.',
    ),
  ],
  'Deep Learning': [
    _c(
      'Networks',
      'a neuron activation',
      'applies a nonlinear function to a weighted input so stacked layers can model nonlinear relationships.',
    ),
    _c(
      'Training',
      'backpropagation',
      'computes gradients of a loss with respect to network parameters using the chain rule.',
    ),
    _c(
      'Training',
      'a learning rate',
      'sets the step scale used by an optimizer when updating model parameters.',
    ),
    _c(
      'Regularization',
      'dropout',
      'randomly disables units during training to discourage co-adaptation and overfitting.',
    ),
    _c(
      'Convolutional models',
      'a convolution layer',
      'applies shared local filters to detect spatial patterns in structured inputs.',
    ),
    _c(
      'Sequence models',
      'an attention mechanism',
      'weights relevant positions in a representation when computing a context-aware output.',
    ),
    _c(
      'Optimization',
      'a batch',
      'is the subset of examples used to calculate one training update.',
    ),
    _c(
      'Optimization',
      'gradient clipping',
      'limits gradient magnitude to reduce unstable parameter updates.',
    ),
    _c(
      'Evaluation',
      'early stopping',
      'ends training when validation performance stops improving to limit overfitting.',
    ),
    _c(
      'Generative models',
      'a latent representation',
      'encodes a compressed internal representation used to model or generate data.',
    ),
  ],
  'Statistics': [
    _c(
      'Descriptive statistics',
      'the mean',
      'is the arithmetic sum of observations divided by their count.',
    ),
    _c(
      'Descriptive statistics',
      'the median',
      'is the middle value after observations are ordered.',
    ),
    _c(
      'Probability',
      'conditional probability',
      'is the probability of an event given that another event is known to have occurred.',
    ),
    _c(
      'Sampling',
      'a sampling distribution',
      'describes how a statistic varies across repeated samples from a population.',
    ),
    _c(
      'Inference',
      'a p-value',
      'is the probability under a specified null model of data at least as extreme as observed.',
    ),
    _c(
      'Inference',
      'a confidence interval',
      'is produced by a procedure that covers the fixed parameter at its stated rate over repeated samples.',
    ),
    _c(
      'Hypothesis testing',
      'a Type I error',
      'rejects a null hypothesis that is actually true.',
    ),
    _c(
      'Hypothesis testing',
      'statistical power',
      'is the probability that a test rejects a false null hypothesis under a specified alternative.',
    ),
    _c(
      'Regression',
      'a residual',
      'is an observed outcome minus the corresponding fitted or predicted outcome.',
    ),
    _c(
      'Study design',
      'random assignment',
      'uses chance to allocate participants and helps balance confounding factors on average.',
    ),
  ],
  'NLP': [
    _c(
      'Text preprocessing',
      'tokenization',
      'splits text into units such as words, subwords, or punctuation tokens.',
    ),
    _c(
      'Text preprocessing',
      'stemming',
      'reduces related word forms using heuristic truncation rules.',
    ),
    _c(
      'Text preprocessing',
      'lemmatization',
      'maps an inflected word to its dictionary form using linguistic information.',
    ),
    _c(
      'Representations',
      'a word embedding',
      'maps a token to a dense vector intended to capture useful semantic relationships.',
    ),
    _c(
      'Language modeling',
      'perplexity',
      'measures how well a probabilistic language model predicts a sequence under its tokenization.',
    ),
    _c(
      'Sequence labeling',
      'named entity recognition',
      'identifies spans of text that refer to entity types such as people or locations.',
    ),
    _c(
      'Text classification',
      'a confusion matrix',
      'summarizes predicted versus actual classes for a classifier.',
    ),
    _c(
      'Attention',
      'self-attention',
      'lets each sequence position compute a representation from other positions in the same sequence.',
    ),
    _c(
      'Evaluation',
      'BLEU',
      'compares generated text with reference text using modified n-gram precision and a brevity penalty.',
    ),
    _c(
      'Evaluation',
      'human evaluation',
      'uses reviewers to assess qualities such as relevance, factuality, and fluency that automatic metrics may miss.',
    ),
  ],
  'Power BI': [
    _c(
      'Modeling',
      'a star schema',
      'organizes analytics data into fact tables connected to descriptive dimension tables.',
    ),
    _c(
      'Modeling',
      'a relationship',
      'defines how rows in related model tables filter and combine.',
    ),
    _c(
      'DAX',
      'a measure',
      'calculates an aggregate expression dynamically under the current filter context.',
    ),
    _c(
      'DAX',
      'a calculated column',
      'evaluates a row-level expression and stores its result in the model.',
    ),
    _c(
      'DAX',
      'filter context',
      'is the set of filters that affects a measure’s calculation.',
    ),
    _c(
      'Power Query',
      'query folding',
      'pushes supported transformation steps back to the source system for execution.',
    ),
    _c(
      'Reports',
      'a slicer',
      'lets report readers interactively filter data by selected values.',
    ),
    _c(
      'Reports',
      'drill-through',
      'navigates from a summary to a detail page filtered for a selected data point.',
    ),
    _c(
      'Refresh',
      'incremental refresh',
      'updates recent partitions while retaining older historical partitions.',
    ),
    _c(
      'Governance',
      'row-level security',
      'restricts which model rows a user can see based on role rules.',
    ),
  ],
  'Excel': [
    _c(
      'Formulas',
      'a relative reference',
      'adjusts its row and column when a formula is copied to another cell.',
    ),
    _c(
      'Formulas',
      'an absolute reference',
      'keeps its referenced row and column fixed when a formula is copied.',
    ),
    _c(
      'Lookups',
      'XLOOKUP',
      'searches a range or array and returns a corresponding result from another range.',
    ),
    _c(
      'Aggregation',
      'SUMIFS',
      'adds values that satisfy multiple criteria ranges.',
    ),
    _c(
      'Tables',
      'a structured reference',
      'uses table and column names in a formula instead of fixed cell coordinates.',
    ),
    _c(
      'Analysis',
      'a PivotTable',
      'summarizes and rearranges source data interactively by fields and aggregates.',
    ),
    _c(
      'Data quality',
      'data validation',
      'restricts cell entries to defined rules such as a list, range, or date.',
    ),
    _c(
      'Visualization',
      'conditional formatting',
      'changes cell appearance automatically based on values or rules.',
    ),
    _c(
      'What-if analysis',
      'Goal Seek',
      'finds an input value that makes a formula reach a specified result.',
    ),
    _c(
      'Import',
      'Power Query',
      'connects to data sources and records repeatable transformation steps before loading data.',
    ),
  ],
  'PySpark': [
    _c(
      'Execution',
      'a DataFrame transformation',
      'builds a lazy distributed query plan without immediately computing its results.',
    ),
    _c(
      'Execution',
      'a Spark action',
      'requests a result or output and triggers execution of the pending plan.',
    ),
    _c(
      'Schemas',
      'an explicit schema',
      'declares field names and types so input data is interpreted predictably.',
    ),
    _c(
      'Performance',
      'a shuffle',
      'redistributes records across partitions and commonly occurs in grouping or joining.',
    ),
    _c(
      'Driver memory',
      'collect',
      'copies all result rows to the driver and should only be used when the result is small.',
    ),
    _c(
      'Streaming',
      'a checkpoint',
      'stores streaming progress and state needed to recover a query.',
    ),
    _c(
      'Data quality',
      'dropDuplicates with selected keys',
      'deduplicates records according to the explicitly chosen business key.',
    ),
    _c(
      'Performance',
      'a built-in Spark expression',
      'is visible to the optimizer and often avoids Python serialization overhead.',
    ),
    _c(
      'Performance',
      'data skew',
      'causes uneven partition sizes when a small number of keys dominate the records.',
    ),
    _c(
      'Joins',
      'a broadcast join',
      'copies a suitably small relation to executors to avoid shuffling the larger relation.',
    ),
  ],
  'Apache Spark': [
    _c(
      'Architecture',
      'the driver',
      'creates the application plan and coordinates work executed by cluster executors.',
    ),
    _c(
      'Architecture',
      'an executor',
      'runs tasks and can cache data for a Spark application on a worker node.',
    ),
    _c(
      'Execution',
      'a directed acyclic graph',
      'represents dependencies between transformations in a Spark job.',
    ),
    _c(
      'Execution',
      'a stage',
      'groups tasks that can run without crossing a shuffle boundary.',
    ),
    _c(
      'Execution',
      'a task',
      'is a unit of work applied to one partition during a stage.',
    ),
    _c(
      'Data abstractions',
      'an RDD',
      'is an immutable distributed collection that supports partitioned transformations.',
    ),
    _c(
      'Performance',
      'a narrow transformation',
      'computes output partitions from a limited set of input partitions without a shuffle.',
    ),
    _c(
      'Performance',
      'a wide transformation',
      'requires data exchange across partitions and creates a shuffle boundary.',
    ),
    _c(
      'Fault tolerance',
      'lineage',
      'records dependency information that can be used to recompute lost partitions.',
    ),
    _c(
      'Storage',
      'cache persistence',
      'retains a reused dataset across actions when its storage level and memory permit.',
    ),
  ],
  'Databricks': [
    _c(
      'Architecture',
      'a workspace',
      'provides an environment for organizing notebooks, jobs, compute, and collaboration.',
    ),
    _c(
      'Architecture',
      'a cluster',
      'provides compute resources on which Spark workloads and notebooks can execute.',
    ),
    _c(
      'Lakehouse',
      'the bronze layer',
      'retains raw or minimally transformed records with source lineage.',
    ),
    _c(
      'Lakehouse',
      'the silver layer',
      'contains cleaned, validated, and conformed records for downstream use.',
    ),
    _c(
      'Lakehouse',
      'the gold layer',
      'contains curated data shaped for business reporting or consumption.',
    ),
    _c(
      'Delta Lake',
      'the transaction log',
      'records table commits and enables consistent versions and transactional operations.',
    ),
    _c(
      'Delta Lake',
      'MERGE',
      'applies matched updates and unmatched inserts using a join condition.',
    ),
    _c(
      'Governance',
      'Unity Catalog',
      'centralizes discovery, permissions, and auditability for governed data assets.',
    ),
    _c(
      'Streaming',
      'a watermark',
      'sets a lateness threshold that can bound state for event-time streaming.',
    ),
    _c(
      'Reliability',
      'an idempotent write',
      'can be retried without creating unintended duplicate effects for the same logical input.',
    ),
  ],
  'Azure': [
    _c(
      'Identity',
      'Microsoft Entra ID',
      'provides identity and access management for users, applications, and Azure resources.',
    ),
    _c(
      'Governance',
      'an Azure resource group',
      'organizes related resources that can share lifecycle and access-management operations.',
    ),
    _c(
      'Governance',
      'Azure Policy',
      'evaluates and enforces organizational rules for resource configuration.',
    ),
    _c(
      'Networking',
      'a virtual network',
      'provides an isolated network boundary for Azure resources.',
    ),
    _c(
      'Compute',
      'Azure Functions',
      'runs event-triggered code without requiring the user to manage a dedicated application server.',
    ),
    _c(
      'Storage',
      'Azure Blob Storage',
      'stores unstructured object data such as files, images, and backups.',
    ),
    _c(
      'Secrets',
      'Azure Key Vault',
      'stores and controls access to secrets, keys, and certificates.',
    ),
    _c(
      'Monitoring',
      'Azure Monitor',
      'collects and analyzes metrics, logs, and alerts for Azure resources.',
    ),
    _c(
      'Resilience',
      'an availability zone',
      'is a physically separate location within a region used to improve fault isolation.',
    ),
    _c(
      'Cost management',
      'a budget alert',
      'notifies stakeholders when tracked spending approaches a configured threshold.',
    ),
  ],
  'Azure DevOps': [
    _c(
      'Planning',
      'Azure Boards',
      'tracks work items such as requirements, bugs, tasks, and their relationships.',
    ),
    _c(
      'Source control',
      'a pull request',
      'provides a review and validation point before branch changes are integrated.',
    ),
    _c(
      'Continuous integration',
      'a build pipeline',
      'automates repeatable compilation and validation when source changes.',
    ),
    _c(
      'Agents',
      'a pipeline agent',
      'executes the jobs and tasks defined in a pipeline.',
    ),
    _c(
      'Artifacts',
      'a build artifact',
      'preserves tested build output so later stages can deploy the same version.',
    ),
    _c(
      'Governance',
      'a branch policy',
      'requires reviews or successful checks before protected branch changes are accepted.',
    ),
    _c(
      'Secrets',
      'a secure variable',
      'stores sensitive pipeline input without committing its value into source control.',
    ),
    _c(
      'Deployment',
      'an environment approval',
      'gates deployment to a target environment until required review is completed.',
    ),
    _c(
      'Releases',
      'a deployment stage',
      'promotes a verified artifact through a controlled target environment.',
    ),
    _c(
      'Security',
      'a scoped service connection',
      'limits pipeline access to the specific external resources it needs.',
    ),
  ],
  'Git and GitHub': [
    _c(
      'Version control',
      'a commit',
      'records a snapshot of tracked changes with metadata and a parent reference.',
    ),
    _c(
      'Version control',
      'a branch',
      'is a movable reference that lets work proceed independently from another line of development.',
    ),
    _c(
      'Version control',
      'the staging area',
      'selects which changed content will be included in the next commit.',
    ),
    _c(
      'Synchronization',
      'git fetch',
      'downloads remote references and objects without integrating them into the current branch.',
    ),
    _c(
      'Synchronization',
      'git pull',
      'fetches remote changes and integrates them into the current branch.',
    ),
    _c(
      'Integration',
      'a merge conflict',
      'occurs when Git cannot automatically reconcile overlapping changes.',
    ),
    _c(
      'Collaboration',
      'a GitHub pull request',
      'proposes changes for discussion, review, checks, and eventual integration.',
    ),
    _c(
      'History',
      'git revert',
      'creates a new commit that reverses the effect of an earlier commit.',
    ),
    _c(
      'History',
      'git rebase',
      'replays commits onto a new base to create a different commit history.',
    ),
    _c(
      'Repository hygiene',
      'a .gitignore rule',
      'prevents matching untracked files from being considered for version control.',
    ),
  ],
  'Docker': [
    _c(
      'Images',
      'a Docker image',
      'is a packaged, layered template used to create containers.',
    ),
    _c(
      'Containers',
      'a container',
      'is an isolated running process created from an image.',
    ),
    _c(
      'Builds',
      'a Dockerfile',
      'declares instructions for building a container image.',
    ),
    _c(
      'Builds',
      'a build context',
      'is the set of files made available to the Docker build process.',
    ),
    _c(
      'Storage',
      'a volume',
      'persists container data independently of a container’s writable layer.',
    ),
    _c(
      'Networking',
      'a bridge network',
      'lets containers communicate on a host-managed virtual network.',
    ),
    _c(
      'Security',
      'a non-root container user',
      'reduces privileges available to a process inside the container.',
    ),
    _c(
      'Distribution',
      'a container registry',
      'stores and distributes versioned container images.',
    ),
    _c(
      'Orchestration',
      'Docker Compose',
      'defines and runs a multi-container application from a declarative configuration.',
    ),
    _c(
      'Efficiency',
      'a multi-stage build',
      'uses separate build and runtime stages to reduce the final image contents.',
    ),
  ],
  'Kubernetes': [
    _c(
      'Workloads',
      'a Pod',
      'is the smallest deployable unit and contains one or more co-located containers.',
    ),
    _c(
      'Workloads',
      'a Deployment',
      'manages replicated Pods and supports declarative rolling updates.',
    ),
    _c(
      'Networking',
      'a Service',
      'provides a stable network endpoint for a changing set of Pods.',
    ),
    _c(
      'Configuration',
      'a ConfigMap',
      'supplies non-secret configuration data to workloads.',
    ),
    _c(
      'Configuration',
      'a Secret',
      'stores sensitive configuration separately from ordinary application settings.',
    ),
    _c(
      'Scaling',
      'a Horizontal Pod Autoscaler',
      'adjusts replica count based on configured resource or custom metrics.',
    ),
    _c(
      'Storage',
      'a PersistentVolumeClaim',
      'requests storage with defined capacity and access requirements.',
    ),
    _c(
      'Scheduling',
      'a readiness probe',
      'indicates whether a container is ready to receive traffic.',
    ),
    _c(
      'Scheduling',
      'a liveness probe',
      'indicates whether a container should be restarted because it is unhealthy.',
    ),
    _c(
      'Access control',
      'RBAC',
      'uses roles and bindings to control which identities can perform API actions.',
    ),
  ],
  'Terraform': [
    _c(
      'Configuration',
      'a provider',
      'configures Terraform to manage resources through a particular platform or service API.',
    ),
    _c(
      'Configuration',
      'a resource block',
      'declares an infrastructure object Terraform should create or manage.',
    ),
    _c(
      'Configuration',
      'an input variable',
      'parameterizes a configuration so values can be supplied from outside its modules.',
    ),
    _c(
      'Configuration',
      'an output value',
      'exposes a selected result from a module or root configuration.',
    ),
    _c(
      'State',
      'Terraform state',
      'maps configuration resources to real managed objects and records their attributes.',
    ),
    _c(
      'Planning',
      'terraform plan',
      'shows proposed changes by comparing configuration and state before applying them.',
    ),
    _c(
      'Execution',
      'terraform apply',
      'executes an approved plan to create, update, or destroy managed resources.',
    ),
    _c(
      'Modules',
      'a Terraform module',
      'packages reusable resources and configuration behind a defined interface.',
    ),
    _c(
      'State safety',
      'a remote state backend',
      'stores shared state centrally and can support locking and collaboration.',
    ),
    _c(
      'Dependencies',
      'a data source',
      'reads information about an existing object without declaring that object for creation.',
    ),
  ],
  'CI/CD Pipelines': [
    _c(
      'Continuous integration',
      'continuous integration',
      'integrates small changes frequently and runs automated build and test checks.',
    ),
    _c(
      'Continuous delivery',
      'continuous delivery',
      'keeps validated software deployable while retaining a release decision.',
    ),
    _c(
      'Continuous deployment',
      'continuous deployment',
      'automatically releases changes that pass the defined production gates.',
    ),
    _c(
      'Builds',
      'a pipeline artifact',
      'preserves a versioned build output for later verification or deployment.',
    ),
    _c(
      'Testing',
      'a quality gate',
      'blocks promotion when required tests, scans, or policies fail.',
    ),
    _c(
      'Deployment',
      'a canary release',
      'routes a limited portion of traffic to a new version before wider rollout.',
    ),
    _c(
      'Deployment',
      'a blue-green deployment',
      'switches traffic between separately prepared old and new environments.',
    ),
    _c(
      'Security',
      'a secret store',
      'supplies credentials to jobs without embedding secret values in source or logs.',
    ),
    _c(
      'Reliability',
      'a rollback strategy',
      'restores a known-good version when a release causes unacceptable behavior.',
    ),
    _c(
      'Operations',
      'deployment observability',
      'uses logs, metrics, and traces to evaluate a release’s behavior after promotion.',
    ),
  ],
  'Technical Fundamentals': [
    _c(
      'HTTP',
      'the GET method',
      'requests a representation of a resource and is intended to be safe and idempotent.',
    ),
    _c(
      'HTTP',
      'the POST method',
      'submits data for processing and may create a resource or trigger an operation.',
    ),
    _c(
      'HTTP',
      'status code 201',
      'indicates that a request successfully created a resource.',
    ),
    _c(
      'Networking',
      'DNS',
      'translates domain names into records such as IP addresses used to locate services.',
    ),
    _c(
      'Security',
      'authentication',
      'establishes the identity associated with a user or system.',
    ),
    _c(
      'Security',
      'authorization',
      'decides which actions an authenticated identity is permitted to perform.',
    ),
    _c(
      'Security',
      'least privilege',
      'grants only the access needed for a task and no broader permissions.',
    ),
    _c(
      'Databases',
      'a transaction',
      'groups operations into a unit with defined commit and rollback behavior.',
    ),
    _c(
      'Testing',
      'a unit test',
      'checks a small unit of behavior in isolation from unrelated system components.',
    ),
    _c(
      'Performance',
      'a cache',
      'reuses previously computed or retrieved values to reduce repeated work.',
    ),
  ],
};
