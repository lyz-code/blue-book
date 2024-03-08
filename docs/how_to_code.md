Over the years I've tried different ways of developing my code: 

- Mindless coding: write code as you need to make it work, with no tests, documentation or any quality measure.
- TDD.
- Try to abstract everything to minimize the duplication of code between projects.

Each has it's advantages and disadvantages. After trying them all and given that right now I only have short spikes of energy and time to invest in coding my plan for new programs is to:

- Make the minimum design effort to solve the problem at hand. This design will be represented in an [orgmode](orgmode.md) task.
- Write the minimum code to make it work without thinking of tests or generalization, but with the [domain driven design](domain_driven_design.md) concepts so the code remains flexible and maintainable.
- If tests come to your mind, sketch them in a test.py file even if they are empty tests.
- Once it's working see if I have time to improve it:
  - Create the tests to cover the critical functionality (no more 100% coverage).
  - If I need to make a package or the program evolves into something complex I'd use [this scaffold template](https://github.com/lyz-code/cookiecutter-python-project).

Once the spike is over I'll wait for a new spike to come either because I have time or because something breaks and I need to fix it.

If the code to edit is already at production quality level and has tests, then do a test for each of the changes with TDD.
[![](not-by-ai.svg){: .center}](https://notbyai.fyi)
