#! /bin/bash

echo '' > instructions.md

echo '* [Setup](#setup)' >> instructions.md

echo '* [Backend](#backend)' >> instructions.md
echo '  * [Models](#backend-models)' >> instructions.md
echo '    * [Users](#backend-user-model)' >> instructions.md
echo '    * [Subs](#backend-sub-model)' >> instructions.md
echo '    * [Posts](#backend-post-model)' >> instructions.md
echo '      * [User Association](#backend-user-post-model-association)' >> instructions.md
echo '      * [Sub Association](#backend-sub-post-model-association)' >> instructions.md
echo '  * [Controllers](#backend-controllers)' >> instructions.md
echo '    * [Users](#backend-users-controller)' >> instructions.md
echo '    * [Subs](#backend-subs-controller)' >> instructions.md
echo '    * [Posts](#backend-posts-controller)' >> instructions.md
echo '      * [User Association](#backend-user-post-controller-association)' >> instructions.md
echo '      * [Sub Association](#backend-sub-post-controller-association)' >> instructions.md

echo '* [Frontend](#frontend)' >> instructions.md
echo '  * [Http](#frontend-http)' >> instructions.md
echo '  * [Models](#frontend-models)' >> instructions.md
echo '    * [Heartbeats](#frontend-heartbeat-model)' >> instructions.md
echo '    * [Users](#frontend-user-model)' >> instructions.md
echo '    * [Subs](#frontend-sub-model)' >> instructions.md
echo '    * [Posts](#frontend-post-model)' >> instructions.md

echo '* [Auth](#auth)' >> instructions.md
echo '  * [Salt](#auth-salt)' >> instructions.md
echo '  * [Cipher](#auth-cipher)' >> instructions.md

echo '' >> instructions.md

echo -e '# Reset\n' >> instructions.md
cat setup/reset.md >> instructions.md

echo -e '# Installs\n' >> instructions.md
cat setup/installs.md >> instructions.md

echo -e '# Setup\n' >> instructions.md
cat setup/setup.md >> instructions.md



echo -e '# Backend\n' >> instructions.md
cat backend/setup.md >> instructions.md

echo -e '## Backend Models\n' >> instructions.md
cat backend/models/setup.md >> instructions.md

echo -e '### Backend User Model\n' >> instructions.md
cat backend/models/users.md >> instructions.md

echo -e '### Backend Sub Model\n' >> instructions.md
cat backend/models/subs.md >> instructions.md

echo -e '### Backend Post Model\n' >> instructions.md
cat backend/models/posts.md >> instructions.md

echo -e '#### Backend User Post Model Association\n' >> instructions.md
cat backend/models/posts/user_association.md >> instructions.md

echo -e '#### Backend Sub Post Model Association\n' >> instructions.md
cat backend/models/posts/sub_association.md >> instructions.md

echo -e '## Backend Controllers\n' >> instructions.md
cat backend/controllers/setup.md >> instructions.md

echo -e '### Backend Users Controller\n' >> instructions.md
cat backend/controllers/users.md >> instructions.md

echo -e '### Backend Subs Controller\n' >> instructions.md
cat backend/controllers/subs.md >> instructions.md

echo -e '### Backend Posts Controller\n' >> instructions.md
cat backend/controllers/posts.md >> instructions.md

echo -e '#### Backend User Post Controller Association\n' >> instructions.md
cat backend/controllers/posts/user_association.md >> instructions.md

echo -e '#### Backend Sub Post Controller Association\n' >> instructions.md
cat backend/controllers/posts/sub_association.md >> instructions.md



echo -e '# Frontend\n' >> instructions.md
cat frontend/setup.md >> instructions.md

echo -e '## Frontend Http\n' >> instructions.md
cat frontend/http/setup.md >> instructions.md

echo -e '## Frontend Models\n' >> instructions.md
cat frontend/models/setup.md >> instructions.md

echo -e '### Frontend Heartbeat Model\n' >> instructions.md
cat frontend/models/heartbeats.md >> instructions.md

echo -e '### Frontend User Model\n' >> instructions.md
cat frontend/models/users.md >> instructions.md

echo -e '### Frontend Sub Model\n' >> instructions.md
cat frontend/models/subs.md >> instructions.md

echo -e '### Frontend Post Model\n' >> instructions.md
cat frontend/models/posts.md >> instructions.md



echo -e '# Auth\n' >> instructions.md
cat auth/setup.md >> instructions.md

echo -e '# Auth Salt\n' >> instructions.md
cat auth/salt.md >> instructions.md

echo -e '# Auth Cipher\n' >> instructions.md
cat auth/cipher.md >> instructions.md
