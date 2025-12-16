# config/initializers/custom_parameterize.rb
Rails.application.config.after_initialize do
  require 'babosa'

  # Define the regex outside the method for performance
  CYRILLIC_REGEX = /\p{Cyrillic}/

  # Monkey-patch String to override parameterize behavior
  class String
    # Alias the original method so we can call it later
    alias_method :original_parameterize, :parameterize

    # Override the standard parameterize method
    def parameterize(separator: "-", preserve_case: false)
      transliterated_string = self

      # 1. Apply robust transliteration using Babosa's logic
      babosa_string = self.to_slug

      # Use the specific Russian rule if Cyrillic is detected for better accuracy
      if self.match?(CYRILLIC_REGEX)
        transliterated_string = babosa_string.transliterate(:russian).to_s
      else
        # For all other languages, use Babosa's generic transliteration
        transliterated_string = babosa_string.transliterate.to_s
      end

      # 2. Call the original Rails parameterize method
      # This applies the final lowercasing, space-to-separator conversion,
      # and character stripping, using the new, fully transliterated string.
      transliterated_string.original_parameterize(separator: separator, preserve_case: preserve_case)
    end
  end
end