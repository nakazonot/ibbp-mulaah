class AddListAllowSitesForSharing < ActiveRecord::Migration[5.1]
  def change
    Parameter.create([
      { name: 'referral.social_share_buttons', description: 'List of social networks on which users can share their referral link through social share buttons (comma separated): twitter, facebook, google_plus, weibo, qq, douban, google_bookmark, delicious, tumblr, pinterest, email, linkedin, wechat, vkontakte, xing, reddit, hacker_news, telegram, odnoklassniki' },
      { name: 'site.og.title', description: 'Open Graph tag. The title for your shared ICO site link as it should appear in social media.' },
      { name: 'site.og.image', description: 'Open Graph tag. URL to the image that should represent the shared ICO site link.' },
      { name: 'site.og.image.width', description: 'Open Graph tag. Width (in pixels) of the image representing the shared ICO site link.' },
      { name: 'site.og.image.height', description: 'Open Graph tag. Height (in pixels) of the image representing the shared ICO site link.' },
      { name: 'site.og.description', description: 'Open Graph tag. A one to two sentence description complementing the shared ICO site link.' },
      { name: 'site.description', description: 'A one to two sentence description complementing the shared ICO site link.' }
    ])
  end
end
