class StandardError
  def as_json(options={:skip_types => true})
    h = {:error => self.message}
    h[:code] = code if self.respond_to?("code")
    h
  end
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.tag!(:code, code) if self.respond_to?("code")
    xml.tag!(:error, message)
  end
end