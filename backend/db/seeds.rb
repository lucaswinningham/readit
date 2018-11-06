User.create name: 'reddituser', email: 'reddituser@email.com'
Sub.create name: 'redditsub'

# og_user = FactoryBot.create :user, name: 'reddituser', email: 'reddituser@email.com'
# og_sub = FactoryBot.create :sub, name: 'redditsub'

# TODO: get FactoryBot to work

# users = 5.times.map { FactoryBot.create :user }.concat(og_user)
# subs = 5.times.map { FactoryBot.create :sub }.concat(og_sub)

# 100.times do
#   user = users.sample
#   sub = subs.sample
#   FactoryBot.create :post, user: user, sub: sub
# end
