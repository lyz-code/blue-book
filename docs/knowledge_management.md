
# How to learn

## [How to read](https://fs.blog/levels-of-reading/)

When reading for purposes other than entertainment, we typically aim to achieve one of two outcomes: acquiring information or deepening our understanding. Reading for entertainment is straightforward and requires no further explanation.

### Reading for Information vs. Understanding

- **Reading for Information**: This involves consuming content that is easy to digest, such as news articles or casual reading materials. It increases our knowledge but doesn’t necessarily enhance our understanding of a topic.
  
- **Reading for Understanding**: This type of reading involves engaging with works by authors who possess greater expertise on a subject. Such reading challenges our current knowledge and can either refine our understanding or reveal its limitations.

### The Four Levels of Reading

Reading can be broken down into four cumulative levels, each building upon the previous one:

1. **Elementary Reading**  
   This is the basic reading skill we learn in elementary school.

2. **Inspectional Reading**  
   This level involves quickly getting the gist of a text in a limited amount of time. The goal is to decide whether to read the text in its entirety and to understand its general structure and key points.  
   - **Systematic Skimming**: Skim the introduction, table of contents, index, and key chapters to identify the main ideas. Jump in and out, reading a paragraph here and there.
   - **Superficial Reading**: Read through the book quickly without pausing to deeply analyze or reflect. The focus is on covering most of the content to get a broad overview so expect not to  understand all the nuances.

3. **Analytical Reading**  
   This is a thorough and detailed form of reading aimed at deep understanding. It requires active engagement with the text, including marking important passages, asking questions, and making notes in the margins.  
   - **Deep Analysis**: Engage with the text by:
     - Underline major points
     - Use vertical lines in the margin for longer passages
     - Mark important statements with stars or asterisks
     - Number sequences of points in an argument
     - Cross-reference related ideas with page numbers
     - Circle keywords or phrases
     - Write questions and answers in the margins
   - **[Incremental reading](https://en.wikipedia.org/wiki/Incremental_reading)**: is a software-assisted method for learning and retaining information from reading, which involves the creation of flashcards out of electronic articles. "Incremental reading" means "reading in portions". Instead of a linear reading of text one at a time, the method works by keeping a large list of electronic articles or books (often dozens or hundreds) and reading parts of several articles in each session. The user prioritizes articles in the reading list. During reading, key points of articles are broken up into flashcards, which are then learned and reviewed over an extended period with the help of a spaced repetition algorithm.

4. **Syntopical Reading**  
   The most advanced level, syntopical reading, involves reading multiple books on the same subject and synthesizing the information to construct a new understanding. This comparative approach requires placing various texts in conversation with each other, allowing the reader to develop insights that may not be explicitly stated in any single source.

## How to Do Analytical Reading

I organize my learning topics in a `learn.org` document structured as follows:

```org
* DOING Learn to apply joyful militancy concepts.
  - [ ] [[*Analytical read the Joyful militancy book]]
* TODO Improve efficiency
  - [ ] [[*Analytical read Four Thousand Weeks by Oliver Burkman]]

* Learn backlog

** Activism
   ...
** Psychology
   ...
** ...
```

The main headings represent the topics I am actively learning, selected during my [roadmap adjustment](roadmap_adjustment.md). These topics typically require analytical reading of specific texts. The approach I take may vary depending on the source material. 

- [e-books](#analytical-reading-on-e-books)
- [books](#analytical-reading-on-books)
- [web browsing](#analytical-reading-while-web-browsing)

### Analytical Reading of E-books

I use Kobo to read and underline technical and political books. Compared to physical books, e-books offer several advantages:

**Pros:**
- Easy export of highlights
- Convenient for incremental reading
- Quick access to a different topics

**Cons:**
- Difficult to take notes in the margins due to Kobo's slow and cumbersome note-making interface

The process goes as follows:

1. **Import the e-book**: I use [`ebops load file.epub`](https://codeberg.org/lyz/ebops) to load the e-book to the e-reader, and create an TODO element in my `books.org` document with the table of contents so that it's easy to add my ideas using Orgzly.
1. **Read linearly:** I read the text in order. Skimming is challenging, especially with unfamiliar topics.
2. **Underline freely:** I highlight extensively without concern for over-marking.
3. **Export highlights:** I use [`ebops export-highlights`](https://codeberg.org/lyz/ebops) to automatically extract the highlights on a `learn.org` document. The highlights are organised  in nested TODO elements for each chapter.
4. **Process key sections:** Select the sections that are more interesting to process. For each of them:
   - Copy and paste the underlined content into the relevant section of my notes, disregarding formatting.
   - Review the mobile notes document for any additional thoughts.
   - Add personal reflections on the topic.
   - Use AI to polish the text.
   - Ask AI to generate [Anki cards](anki.md) based on the content.

### Analytical reading on books
TBD

### Analytical reading while web browsing
TBD

