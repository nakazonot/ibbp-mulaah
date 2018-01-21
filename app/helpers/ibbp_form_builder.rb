class IbbpFormBuilder < ActionView::Helpers::FormBuilder
  def custom_check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    html_result = @template.check_box(@object_name, method, options, checked_value, unchecked_value)
    if @object && @object.errors[method].present?
      html_result = html_result.sub('<div class="field_with_errors">', '')
      html_result = html_result.sub('</div>', '')
      html_result += '<span class="checkbox-material"><span class="check"></span></span>'
    end
    html_result.html_safe
  end
end