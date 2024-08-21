These are some useful AI prompts to help you while you code:

- create a function with type hints and docstring using google style called { } that { }
- create the tests for the function { } adding type hints and following the AAA style where the Act section is represented contains a returns = (thing to test) line or if the function to test doesn't return any value append an # act comment at the end of the line. Use paragraphs to separate the AAA blocks and don't add comments inside the tests for the sections

If you use [espanso](espanso.md) you can simplify the filling up of these prompts on the AI chats. For example:

```yaml
---
matches:
  - trigger: :function
    form: |
      Create a function with:
      - type hints 
      - docstrings for all classes, functions and methods
      - docstring using google style with line length less than 89 characters
      - adding logging traces using the log variable log = logging.getLogger(__name__)
      - Use fstrings instead of %s
      - If you need to open or write a file always set the encoding to utf8
      - If possible add an example in the docstring
      - Just give the code, don't explain anything

      Called [[name]] that:
      [[text]] 
    form_fields:
      text:
        multiline: true
  - trigger: :class
    form: |
      Create a class with:
      - type hints 
      - docstring using google style with line length less than 89 characters
      - use docstrings on the class and each methods
      - adding logging traces using the log variable log = logging.getLogger(__name__)
      - Use fstrings instead of %s
      - If you need to open or write a file always set the encoding to utf8
      - If possible add an example in the docstring
      - Just give the code, don't explain anything

      Called [[name]] that:
      [[text]] 
    form_fields:
      text:
        multiline: true
  - trigger: :tweak
    form: |
      Tweak the next code:
      [[code]] 

      So that: 

      [[text]] 
    form_fields:
      text:
        multiline: true
      code:
        multiline: true
  - trigger: :test
    form: |
      create the tests for the function:
      [[text]] 

      Following the next guidelines:

      - Use pytest
      - Add type hints 
      - Follow the AAA style 
      - Use paragraphs to separate the AAA blocks and don't add comments like # Arrange or # Act or # Act/Assert or # Assert. So the test will only have black lines between sections
      - In the Act section if the function to test returns a value always name that variable result. If the function to test doesn't return any value append an # act comment at the end of the line. 
      - If the test  uses a pytest.raises there is no need to add the # act comment
      - Don't use mocks
      - Use fstrings instead of %s
      - Gather all tests over the same function on a common class
      - If you need to open or write a file always set the encoding to utf8
      - Just give the code, don't explain anything

    form_fields:
      text:
        multiline: true
  - trigger: :refactor
    form: |
     Refactor the next code
     [[code]] 
     with the next conditions
     [[conditions]]
    form_fields:
      code:
        multiline: true
      conditions:
        multiline: true
  - trigger: :polish
    form: |
     Polish the next code
     [[code]] 
     with the next conditions:
     - Use type hints on all functions and methods
     - Add or update the docstring using google style on all classes, functions and methods
     - Wrap the docstring lines so they are smaller than 89 characters
     - All docstrings must start in the same line as the """
     - Add logging traces using the log variable log = logging.getLogger(__name__)
     - Use f-strings instead of %s
     - Just give the code, don't explain anything
    form_fields:
      code:
        multiline: true
  - trigger: :text
    form: |
     Polish the next text by:

     - Summarising each section without losing relevant data
     - Tweak the markdown format
     - Improve the wording

     [[text]] 
    form_fields:
      text:
        multiline: true

  - trigger: :commit
    form: |
     Act as an expert developer. Create a message commit with the next conditions:
     - follow semantic versioning 
     - create a semantic version comment per change
     - include all comments in a raw code block so that it's easy to copy

     for the following diff
     [[text]] 
    form_fields:
      text:
        multiline: true

  - trigger: :readme
    form: |
     Create the README.md taking into account:

     - Use GPLv3 for the license
     - Add Lyz as the author
     - Add an installation section
     - Add an usage section

     of:
     [[text]]

    form_fields:
      text:
        multiline: true
```

# References

- [Awesome chatgpt prompts](https://prompts.chat/)
