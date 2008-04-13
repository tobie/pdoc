require "bluecloth"
class BlueCloth
  CodeBlockClassNameRegexp = /(?:\s*lang(?:uage)?:\s*(\w+)\s*\n)(.*)/
  def transform_code_blocks( str, rs )
    @log.debug " Transforming code blocks"
    class_name = "javascript"
    str.gsub( CodeBlockRegexp ) do |block|
      codeblock = $1
      remainder = $2
      codeblock = codeblock.sub( CodeBlockClassNameRegexp ) do |b|
        class_name = $1
        $2
      end
      # Generate the codeblock
      %{\n\n<pre><code class="%s">%s\n</code></pre>\n\n%s} %
        [ class_name, encode_code( outdent(codeblock), rs ).rstrip, remainder ]
    end
  end
end