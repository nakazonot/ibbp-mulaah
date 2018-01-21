namespace :email do
  desc 'Setting pretty layout to mailer'
  task set_default_layout: :environment do
    result = Translation.
    find_by(key: "message.mailer_layout")&.
    update_attributes(interpolations: %w[content root_url],
      value:
      <<-HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional //EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- saved from url=(0088)https://redmine-3at.s3-eu-central-1.amazonaws.com/files/2017/12/171221140219_email1.html -->
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
   <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta name="x-apple-disable-message-reformatting">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">
      <style type="text/css">
         * {
         text-size-adjust: 100%;
         -ms-text-size-adjust: 100%;
         -moz-text-size-adjust: 100%;
         -webkit-text-size-adjust: 100%;
         }
         html {
         height: 100%;
         width: 100%;
         }
         body {
         height: 100% !important;
         margin: 0 !important;
         padding: 0 !important;
         width: 100% !important;
         mso-line-height-rule: exactly;
         }
         div[style*="margin: 16px 0"] {
         margin: 0 !important;
         }
         table,
         td {
         mso-table-lspace: 0pt;
         mso-table-rspace: 0pt;
         }
         img {
         border: 0;
         height: auto;
         line-height: 100%;
         outline: none;
         text-decoration: none;
         -ms-interpolation-mode: bicubic;
         }
         .ReadMsgBody,
         .ExternalClass {
         width: 100%;
         }
         .ExternalClass,
         .ExternalClass p,
         .ExternalClass span,
         .ExternalClass td,
         .ExternalClass div {
         line-height: 100%;
         }
         p{
         font-family: Helvetica,Arial,sans-serif !important;
         font-size: 14px !important;
         }
         .mail__block a{
            color: #4A90E2;
            font-weight: bold;
         }
      </style>
      <title>Email Subject</title>
   </head>
   <!--[if !mso]><!-->
   <!--<![endif]-->
   <!--[if gte mso 9]>
   <style type="text/css">
      li { text-indent: -1em; }
      table td { border-collapse: collapse; }
   </style>
   <![endif]-->
   <!-- content -->
   <!--[if gte mso 9]>
   <xml>
      <o:OfficeDocumentSettings>
         <o:AllowPNG/>
         <o:PixelsPerInch>96</o:PixelsPerInch>
      </o:OfficeDocumentSettings>
   </xml>
   <![endif]-->
   <body class="body" style="margin: 0; width: 100%;">
      <table class="bodyTable" role="presentation" width="100%" align="left" border="0" cellpadding="0" cellspacing="0" style="width: 100%; margin: 0;">
         <tbody>
            <tr>
               <td class="body__content" align="left" width="100%" valign="top" style="color: #000000; font-family: Helvetica,Arial,sans-serif; font-size: 16px; line-height: 20px;">
                  <div class="container" style="width: 100%; margin: 0 auto; max-width: 600px;">
                     <!--[if mso | IE]>
                     <table class="container__table__ie" role="presentation" border="0" cellpadding="0" cellspacing="0" style=" margin-right: auto; margin-left: auto;width: 600px" width="600" align="center">
                        <tr>
                           <td>
                              <![endif]-->
                              <table class="container__table" role="presentation" border="0" align="center" cellpadding="0" cellspacing="0" width="100%">
                                 <tbody>
                                    <tr class="container__row">
                                       <td class="container__cell" width="100%" align="left" valign="top" style="background-color: #0F4061;" bgcolor="#0F4061">
                                          <div class="mail__block-56 block" style="width: 100%; height: 56px;">
                                             <!--[if mso | IE]>
                                             <table class="block__table__ie" role="presentation" border="0" cellpadding="0" cellspacing="0" style="width: 100%" width="600">
                                                <tr>
                                                   <td>
                                                      <![endif]-->
                                                      <table class="block__table" role="presentation" border="0" align="center" cellpadding="0" cellspacing="0" width="100%">
                                                         <tbody>
                                                            <tr class="block__row">
                                                               <td class="block__cell" width="100%" align="left" valign="top" style="height: 56px;" height="56"> </td>
                                                            </tr>
                                                         </tbody>
                                                      </table>
                                                      <!--[if mso | IE]>
                                                   </td>
                                                </tr>
                                             </table>
                                             <![endif]-->
                                          </div>
                                          <div class="mail__block block" style="background-color: #FFFFFF; border-radius: 10px; margin: 0 auto; max-width: 500px; width: 90%;">
                                             <!--[if mso | IE]>
                                             <table class="block__table__ie" role="presentation" border="0" cellpadding="0" cellspacing="0" style="margin-right: auto; margin-left: auto;width: 500px" width="500" align="center">
                                                <tr>
                                                   <td>
                                                      <![endif]-->
                                                      <table class="block__table" role="presentation" border="0" align="center" cellpadding="0" cellspacing="0" width="100%">
                                                         <tbody>
                                                            <tr class="block__row">
                                                               <td class="block__cell" width="100%" align="left" valign="top" style="text-align: center; padding: 17px 15px 27px; background-color: #FFFFFF; border-radius: 10px;" bgcolor="#FFFFFF">
                                                                  %{content}
                                                                  <div class="mail__line block" style="width: 100%;">
                                                                     <!--[if mso | IE]>
                                                                     <table class="block__table__ie" role="presentation" border="0" cellpadding="0" cellspacing="0" style="margin-right: auto; margin-left: auto;width: 500px" width="500" align="center">
                                                                        <tr>
                                                                           <td>
                                                                              <![endif]-->
                                                                              <table class="block__table" role="presentation" border="0" align="center" cellpadding="0" cellspacing="0" width="100%">
                                                                                 <tbody>
                                                                                    <tr class="block__row">
                                                                                       <td class="block__cell" width="100%" align="left" valign="top" style="border-radius: 10px; background-color: #EDF8FF; padding: 2px 0;" bgcolor="#EDF8FF"> </td>
                                                                                    </tr>
                                                                                 </tbody>
                                                                              </table>
                                                                              <!--[if mso | IE]>
                                                                           </td>
                                                                        </tr>
                                                                     </table>
                                                                     <![endif]-->
                                                                  </div>
                                                                  <p class="mail__finish-text text p" style="display: block; font-family: Helvetica,Arial,sans-serif; color: #0F4061; font-size: 14px; font-weight: 700; line-height: 21px; text-align: center; margin: 22px auto 0;">Best,
                                                                     IBBP Token Team
                                                                  </p>
                                                               </td>
                                                            </tr>
                                                         </tbody>
                                                      </table>
                                                      <!--[if mso | IE]>
                                                   </td>
                                                </tr>
                                             </table>
                                             <![endif]-->
                                          </div>
                                          <div class="mail__block-70 block" style="width: 100%; height: 70px;">
                                             <!--[if mso | IE]>
                                             <table class="block__table__ie" role="presentation" border="0" cellpadding="0" cellspacing="0" style="width: 100%" width="600">
                                                <tr>
                                                   <td>
                                                      <![endif]-->
                                                      <table class="block__table" role="presentation" border="0" align="center" cellpadding="0" cellspacing="0" width="100%">
                                                         <tbody>
                                                            <tr class="block__row">
                                                               <td class="block__cell" width="100%" align="left" valign="top" style="height: 70px;" height="70"> </td>
                                                            </tr>
                                                         </tbody>
                                                      </table>
                                                      <!--[if mso | IE]>
                                                   </td>
                                                </tr>
                                             </table>
                                             <![endif]-->
                                          </div>
                                       </td>
                                    </tr>
                                 </tbody>
                              </table>
                              <!--[if mso | IE]>
                           </td>
                        </tr>
                     </table>
                     <![endif]-->
                  </div>
                  <div class="mail__footer container" style="width: 100%; margin: 0 auto; max-width: 600px;">
                     <!--[if mso | IE]>
                     <table class="container__table__ie" role="presentation" border="0" cellpadding="0" cellspacing="0" style=" margin-right: auto; margin-left: auto;width: 600px" width="600" align="center">
                        <tr>
                           <td>
                              <![endif]-->
                              <table class="container__table" role="presentation" border="0" align="center" cellpadding="0" cellspacing="0" width="100%">
                                 <tbody>
                                    <tr class="container__row">
                                       <td class="container__cell" width="100%" align="left" valign="top" style="background-color: #0F324A; padding: 20px 0 38px;" bgcolor="#0F324A">
                                          <div class="row">
                                             <table class="row__table" width="100%" align="center" role="presentation" border="0" cellpadding="0" cellspacing="0" style="table-layout: fixed;">
                                                <tbody>
                                                   <tr class="row__row">
                                                      <td class="column col-sm-12" width="600" style="width: 100%" align="left" valign="top">
                                                         <p class="mail__footer-text text p" style="display: block; font-family: Helvetica,Arial,sans-serif; line-height: 21px; text-align: center; color: #FFFFFF; font-size: 13px; font-weight: 400; margin: 0 auto 23px;">Need help? <a href="%{root_url}" class="mail__footer-link a" style="color: #23C8C6;"><span class="a__text">Contact
                                                            support</span></a>
                                                         </p>
                                                      </td>
                                                   </tr>
                                                </tbody>
                                             </table>
                                          </div>
                                          <div class="row">
                                             <table class="row__table" width="100%" align="center" role="presentation" border="0" cellpadding="0" cellspacing="0" style="table-layout: fixed;">
                                                <tbody>
                                                   <tr class="row__row">
                                                      <td class="column col-sm-12" width="600" style="width: 100%" align="left" valign="top">
                                                         <div class="mail__net-block" style="text-align: center;">
                                                            <a class="mail__icon-link a" href="%{root_url}" style="color: #4A90E2; display: inline-block; margin: 0 1%; max-width: 24px; width: 10%;">
                                                               <span class="a__text">
                                                                  <img class="mail__icon img__block" src="%{root_url}static/email/telegram.png" border="0" alt="" style="display: block; max-width: 100%; width: 100%;">
                                                               </span>
                                                            </a>
                                                            <a class="mail__icon-link a" href="%{root_url}" style="color: #4A90E2; display: inline-block; margin: 0 1%; max-width: 24px; width: 10%;">
                                                               <span class="a__text">
                                                                  <img class="mail__icon img__block" src="%{root_url}static/email/slack.png" border="0" alt="" style="display: block; max-width: 100%; width: 100%;">
                                                               </span>
                                                            </a>
                                                            <a class="mail__icon-link a" href="%{root_url}" style="color: #4A90E2; display: inline-block; margin: 0 1%; max-width: 24px; width: 10%;">
                                                               <span class="a__text">
                                                                  <img class="mail__icon img__block" src="%{root_url}static/email/phone.png" border="0" alt="" style="display: block; max-width: 100%; width: 100%;">
                                                               </span>
                                                            </a>
                                                         </div>
                                                      </td>
                                                   </tr>
                                                </tbody>
                                             </table>
                                          </div>
                                       </td>
                                    </tr>
                                 </tbody>
                              </table>
                              <!--[if mso | IE]>
                           </td>
                        </tr>
                     </table>
                     <![endif]-->
                  </div>
               </td>
            </tr>
         </tbody>
      </table>
      <div style="display:none; white-space:nowrap; font-size:15px; line-height:0;">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; </div>
   </body>
</html>
      HTML
    )
  puts result ? "OK" : "Something went wrong"
  end
end
