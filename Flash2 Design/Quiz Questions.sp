___ Quiz Questions ___________________________________________________

A //Quiz Question// bundles together everything needed to run a quiz.  This includes:
- The prompts the user will see
- The answers the user is expected to provide
- The layout for these prompts and answers
- The [[cards @Card.sp]], [[user properties @UserProperty.sp]], and [[grammar rules
  @GrammarRule.sp]] that were used to derive each prompt and answer.
  
______ Prompts and Answers ___________________________________________
  
The prompt and answers always take the shape of a rectangular matrix.  The Quiz Question
includes the dimensions of this matrix and the contents of each cell.  Each cell is
configured using an {NSDictionary} into one of several modes.  The mode is indicated
by the value of the {kF2Mode} key:
- {kF2Label}: displays the (potentially attributed) text string {kF2Text}.
- {kF2Prompt}: displays an editable text field.  {kF2PromptId} contains an identifier
  which is used to link the prompt to legal answers as well as associated {Quizzable}s.
- {kF2MergeLeft}: allows a cell to be merged with the one to its left for better layout
  purposes. This is equivalent to a [[colspan
  @http://www.w3.org/TR/html401/struct/tables.html]] in HTML.
More modes may be added later. The spacing of the matrix is automatic and is based on the
length of the text and expected answers.

_________ Sample Layouts _____________________________________________
  
**English equivalent to a Greek word:**
|| διαβάζω | in English is | \[ //prompt with id X// \] ||

**Greek equivalent to an English word:**
|| \[ //prompt with id X// \] | in English is | to read ||

**English word with multiple Greek equivalents:**
|| \[ //prompt with id X// \] | in English is | border ||
|| \[ //prompt with id X// \] | in English is | border ||
Note that both prompts have the same id, meaning that they are asking the same
question.  Two answers will be supplied for the id X, and those answers can be
given in any order.

**Related questions:**
|| ο γιατρός | in English is | \[ //prompt with id X// \] ||
|| ο γιατρός | in the accusative case is | \[ //prompt with id Y// \] ||
Here the two prompts have different ids, because they do not expect the 
same answer.

**Match noun and adjective:**
|| Translate into Greek in the nominative case: | ||
|| the egocentric | doctor ||
|| \[ //prompt with id ADJ// \] | \[ //prompt with id NOUN// \] ||

**Conjugations:**
|| διαβάζω | in 2nd person, present tense is | \[ //prompt with id PRESENT// \] ||
|| διαβάζω | in 2nd person, αόριστος is | \[ //prompt with id AORISTOS// \] ||
etc.

______ Answers and Affected Quizzables _______________________________

Each quiz also has a set of answers, which are a tuple:
- {id}: The prompts for which the answer can be used.
- {text}: The text the user should supply.
- {quizzables}: An {NSArray*} of quizzables being tested.

______ Edit Source ___________________________________________________

Each question also has a set of //question sources//, which are essentially the properties
which were used --- or would have been used, had they been present --- to derive the
answers. Each source is a {(card, relationName)} tuple.  When asked to edit the source
of the question, {Flash2} will display the cards and any user properties that exist for
those relations.  If a given relation does not have a [[@UserProperty.sp]], then the
automatically derived version is shown.  This screen is the same as when editing cards
normally, except that we don't show all possible relations, but only those that are
relevant to the question.  