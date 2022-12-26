import 'funcs_html.dart';
import 'op_attribute_sanitizer.dart';
import 'helpers/url.dart' as url;

class OpLinkSanitizer {
  static String sanitize(String link, OpAttributeSanitizerOptions options) {
    return options.urlSanitizer?.call(link) ?? encodeLink(url.sanitize(link));
  }
}
