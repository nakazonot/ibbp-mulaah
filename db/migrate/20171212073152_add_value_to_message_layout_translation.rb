class AddValueToMessageLayoutTranslation < ActiveRecord::Migration[5.1]
  def change
    Translation.
    find_by(key: "message.mailer_layout").
    update_attributes(interpolations: %w[content root_url],
      value:
      <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  </head>
  <body>
    %{content}
  </body>
</html>
      HTML
    )
  end
end
