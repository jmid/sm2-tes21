Mandatory change assignment - deadline 15/03/2021 12:00 (lunch):
----------------------------------------------------------------

- First log on to https://gitlab.sdu.dk

  You will need to set a GitLab password.

- Afterwards visit this invitation link in your web browser to sign up for the assignment:

  > https://scalableteaching.sdu.dk/assignment/join/0cefcabb-d77b-44d3-aa80-6edb68b88373

- Visiting the link also constructs a private GitLab repository for you. You can find your private repository listed here: https://gitlab.sdu.dk/

  For example, if your username is `foobar18` the repository is https://gitlab.sdu.dk/Scalableteaching/Functional_Programming_and_Property_Based_Testing_Change/foobar18

  (remember to replace the username `foobar18` with your own)

- Clone your private git repository (you'll be asked for your GitLab password from above):
  ```
   $ git clone https://gitlab.sdu.dk/Scalableteaching/Functional_Programming_and_Property_Based_Testing_Change/foobar18.git 

  ```
  (remember to replace the username `foobar18` with your own)

  This downloads a local copy of the repository for you to work on.

- Implement and QuickCheck the function `change` as described in the private repository's README.md file

- Commit and push your local changes to your private repository:
  ```
   $ git commit -m "your commit message" src/change.ml src/changetest.ml
   $ git push -u origin master
  ``` 
  Doing so will trigger a continuous integration test. 
  You can also test your implementation locally as described in the private repository's README.md file.

  **Don't edit and commit changes to any other files than `src/change.ml` and `src/changetest.ml`.**