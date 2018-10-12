#! /bin/bash

echo '' > instructions.md

echo '* [Setup](#setup)' >> instructions.md

echo '* [Backend](#backend)' >> instructions.md
echo '  * [Models](#backend-models)' >> instructions.md
echo '    * [Users](#backend-user-model)' >> instructions.md
echo '    * [Subs](#backend-sub-model)' >> instructions.md
echo '    * [Posts](#backend-post-model)' >> instructions.md
echo '  * [Controllers](#backend-controllers)' >> instructions.md
echo '    * [Users](#backend-users-controller)' >> instructions.md
echo '    * [Subs](#backend-subs-controller)' >> instructions.md
echo '    * [Posts](#backend-posts-controller)' >> instructions.md


for topic in setup backend; do
  cd ${topic}/
  instructions=${instructions}$(./${topic}_build.sh)
  cd ..
done

echo "$instructions" >> instructions.md


# echo '[frontend](frontend/instructions.md)' >> instructions.md
# echo '' >> instructions.md

# echo '[auth](auth/instructions.md)' >> instructions.md
# echo '' >> instructions.md

# cd setup/ && ./setup_build.sh && cd ..
# cd backend/ && ./backend_build.sh && cd ..
# cd frontend/ && ./build.sh && cd ..
# cd auth/ && ./build.sh && cd ..

# cat setup/setup_instructions.md >> instructions.md
# cat backend/backend_instructions.md >> instructions.md
# cat frontend/instructions.md >> instructions.md
# cat auth/instructions.md >> instructions.md


# cat backend/setup.md >> ../README.md

# cat backend/models/setup.md >> ../README.md
# cat backend/models/users.md >> ../README.md
# cat backend/models/subs.md >> ../README.md
# cat backend/models/posts.md >> ../README.md
# # cat backend/models/comments.md >> ../README.md
# # cat backend/models/votes.md >> ../README.md
# # cat backend/models/favorites.md >> ../README.md
# # cat backend/models/follows.md >> ../README.md
# # cat backend/models/assignments.md >> ../README.md
# # cat backend/models/moderations.md >> ../README.md

# # cat backend/serializers/setup.md >> ../README.md

# cat backend/controllers/setup.md >> ../README.md
# cat backend/controllers/users.md >> ../README.md
# cat backend/controllers/subs.md >> ../README.md
# cat backend/controllers/posts.md >> ../README.md
# # cat backend/controllers/comments.md >> ../README.md
# # cat backend/controllers/votes.md >> ../README.md
# # cat backend/controllers/favorites.md >> ../README.md
# # cat backend/controllers/follows.md >> ../README.md
# # cat backend/controllers/assignments.md >> ../README.md
# # cat backend/controllers/moderations.md >> ../README.md

# cat frontend/setup.md >> ../README.md

# cat auth/setup.md >> ../README.md

# # cat frontend/setup.md >> ../README.md