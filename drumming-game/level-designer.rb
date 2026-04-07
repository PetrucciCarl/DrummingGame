def draw_level_designer(game_data)
    #get the images
    note_image = Gosu::Image.new("media/note.png")
    note_empty_image = Gosu::Image.new("media/note_empty.png")
    note_selected_image = Gosu::Image.new("media/note_not_hit.png")
    note_testing_image = Gosu::Image.new("media/note_hit.png")
    background_image = Gosu::Image.new("media/background2.png")
    background_image.draw(0, 0, ZOrder::BACK)
    #draw input for bpm
    game_data.bpm_box = BoxCollision.new(40, 10, 150, 30, game_data)
    if ui_hovered(game_data.bpm_box)
        @font.draw_text("bpm: #{game_data.bpm}", 30, 10, ZOrder::MIDDLE, scale_x = 2, scale_y = 2, colour = Gosu::Color.argb(0xffffaa00))
    else
        @font.draw_text("bpm: #{game_data.bpm}", 30, 10, ZOrder::MIDDLE, scale_x = 2, scale_y = 2, colour = Gosu::Color::BLACK)
    end
    #draw test button
    test_button = Button.new(400, 10, 80, 50, "test", 0, :test, game_data)
    draw_button(test_button)
    #draw save button
    save_button = Button.new(360, 400, 200, 50, "save & exit", 0, :go_to_level_save, game_data)
    draw_button(save_button)
    #draw button for adding new beat
    beat_button = Button.new(520, 10, 60, 50, "add", 0, :add_beat, game_data)
    draw_button(beat_button)

    #for each beat draw it in the correct possition and the correct colour
    count = game_data.beats.size()
    index = 0
    while (index < count)
        game_data.beats[index].x = game_data.beats[index].index * 80
        game_data.beats[index].x += game_data.x_offset
        #checks if the mouse is hovering over the beat
        if (ui_hovered(game_data.beats[index]))
            note_selected_image.draw(game_data.beats[index].x, game_data.beats[index].y, ZOrder::FRONT)
        else
            #checks the 'hit' state of the beat
            if (game_data.beats[index].hit)
                note_image.draw(game_data.beats[index].x, game_data.beats[index].y, ZOrder::FRONT)
            else
                note_empty_image.draw(game_data.beats[index].x, game_data.beats[index].y, ZOrder::FRONT)
            end
        end
        #makes the beat green if it is being tested
        if (game_data.testing && index == game_data.test_index)
            if (game_data.beats[index].hit)
                note_testing_image.draw(game_data.beats[index].x, game_data.beats[index].y, ZOrder::FRONT)
            end
            game_data.test_frame += 1
            #move to the next beat every seconds per minute times frames per second divided by beats per minute
            if (game_data.test_frame > 3600.0 / game_data.bpm.to_f())
                game_data.test_index += 1
                game_data.test_frame = 0
                #stop playing the audio once the last beat has been reached
                if (game_data.test_index + 1 > game_data.beats.size())
                    game_data.audio_file.stop()
                end
            end
        end 
        game_data.beats[index].x -= game_data.x_offset
        index += 1
    end
    return game_data
end

#function begins the testing of beats
def test(game_data)
    game_data.audio_file.stop()
    game_data.audio_file.play()
    game_data.test_frame = 0
    game_data.test_index = 0
    game_data.testing = true
    return game_data
end

#function adds a new beat
def add_beat(game_data)
    if  (game_data.mouse_released)
        game_data.beats << Beat.new(game_data.beats.size() * 80, game_data.beats.size(), false)
        game_data.mouse_released = false
    end
    return game_data
end

#function opens up file dialoge where the user can name their level, then saves the data
def go_to_level_save(game_data)
    game_data.audio_file.stop()
    save_path = Tk.getSaveFile(initialdir: "levels")
    if save_path != ""
        save_file = File.new(save_path, "w")
        save_file.puts(game_data.bpm)
        save_file.puts(game_data.audio_path)
        save_file.puts(0)
        save_file.puts(0)
        save_file.puts(0)
        save_file.puts(game_data.beats.size())
        count = game_data.beats.size()
        index = 0
        while (index < count)
            save_file.puts(game_data.beats[index].hit)
            index += 1
        end
        save_file.close()
    end
    go_to_title(game_data)
    return game_data
end

#function directs users to the level designer screen
def go_to_level_designer(game_data)
    game_data.x_offset = 0
    game_data.current_screen = Menu::LEVEL_DESIGNER
    return game_data
end