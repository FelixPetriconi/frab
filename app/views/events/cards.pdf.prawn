prawn_document(:page_layout => :landscape) do |pdf|

  pdf.font_families.update("BitStream Vera" => {
    :normal => File.join(Rails.root, "vendor", "fonts", "vera.ttf"),
    :bold => File.join(Rails.root, "vendor", "fonts", "verabd.ttf"),
    :italic => File.join(Rails.root, "vendor", "fonts", "verait.ttf")
  })
  pdf.font "BitStream Vera"

  pdf.define_grid(:rows => 2, :columns => 2, :gutter => 10)

  (@events.size / 4 + 1).times do
    
    [[0,0],[0,1],[1,0],[1,1]].each do |coords|

      if event = @events.pop
        pdf.grid(coords[0], coords[1]).bounding_box do
          title = event.title.truncate(100)
          pdf.text(title, :size => 16, :style => :bold, :skip_encoding => true)
          subtitle = (event.subtitle || "").truncate(40)
          pdf.text(subtitle, :size => 14, :style => :italic)
          speakers = event.event_people.select{|p| p.event_role == "speaker"}.map{|p| p.person.full_name}
          pdf.formatted_text_box(
            [{:text => "Speakers:\n", :styles => [:bold], :size => 12},
             {:text => speakers.join("\n"), :size => 12}],
            :at => [0,200], 
            :width => 100
          )
          abstract = (event.abstract || event.description || "").gsub(/(\r\n|\n)/, " ").truncate(180)
          logger.info("ABSTRACT: #{abstract}")
          pdf.formatted_text_box(
            [{:text => "Abstract:\n", :styles => [:bold], :size => 12},
             {:text => abstract, :size => 12}],
            :at => [100,200],
            :width => 200,
            :overflow => :expand,
            :skip_encoding => true
          )
          pdf.move_cursor_to 80
          pdf.table(
            [[event.track.try(:name), event.event_type, event.language, format_time_slots(event.time_slots)]],
            :width => 300,
            :cell_style => {:align => :center}
          )
        end
      end

    end

    pdf.start_new_page unless @events.empty?
  
  end

end
