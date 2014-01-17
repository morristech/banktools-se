# http://www.bgc.se/upload/Gemensamt/Trycksaker/Manualer/BG6070.pdf section 5.2

module BankTools
  module SE
    class Bankgiro
      class OverlongOCR < StandardError; end
      class BadCheckDigit < StandardError; end

      class OCR
        def self.number_to_ocr(number, opts = {})
          add_length_digit = opts.fetch(:length_digit, false)
          pad = opts.fetch(:pad, nil)

          number = number.to_s

          if pad
            number += pad
          end

          if add_length_digit
            # Adding 2: 1 length digit, 1 check digit
            number += ((number.length + 2) % 10).to_s
          end

          number_with_ocr = number.to_s + Utils.luhn_checksum(number).to_s
          raise OverlongOCR, "Bankgiro OCR must be 2-25 characters" if number_with_ocr.length > 25
          number_with_ocr
        end

        def self.number_from_ocr(number, opts = {})
          strip_length_digit = opts.fetch(:length_digit, false)
          strip_padding = opts.fetch(:pad, false)

          raise BadCheckDigit unless Utils.valid_luhn?(number)

          number = number.to_s
          number.slice!(-2) if strip_length_digit
          number.slice!(-strip_padding.length.succ..-2) if strip_padding
          number.chop
        end
      end
    end
  end
end
