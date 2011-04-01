require "spec/helper"

# describe "script tags" do
#   it "treat script tag special" do
#     dang = "
# <script
# var _gaq = _gaq || [];
# _gaq.push(['_setAccount', 'UA-193482-20']);
# _gaq.push(['_trackPageview']);
# 
# (function() {
#   var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
#   ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
#   var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
#   })();
# script>
# "
# 
#     html = "
# <script>
# var _gaq = _gaq || [];
# _gaq.push(['_setAccount', 'UA-193482-20']);
# _gaq.push(['_trackPageview']);
# 
# (function() {
#   var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
#   ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
#   var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
#   })();
# <script>
# "
# 
#     Dang.it(dang).must_equal html
#   end
# end
