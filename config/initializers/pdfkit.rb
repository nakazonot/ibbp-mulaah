require 'pdfkit'
class PDFKit
  class Configuration
    def wkhtmltopdf
      @wkhtmltopdf ||= `which wkhtmltopdf`.chomp
    end
  end
end

PDFKit.configure do |config|
  config.default_options = {
    page_size: 'A4',
    margin_left: '2.5cm',
    margin_right: '2.5cm',
    margin_top: '2.5cm',
    margin_bottom: '2.5cm',
    footer_center: '-C-[page]-',
    footer_spacing: '6',
    footer_font_size: 12,
    footer_font_name: '"Times New Roman", serif',
  }
end