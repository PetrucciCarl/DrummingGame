def draw_game(game_data)
    background_image = Gosu::Image.new("media/background0.png")
    note_not_hit_image = Gosu::Image.new("media/note_not_hit.png")
    note_hit_image = Gosu::Image.new("media/note_hit.png")
    #draw background in any colour
    background_image.draw(0, 0, ZOrder::BACK)
    #draw the bar which shows the player where to hit
    drumstick_image = Gosu::Image.new("media/drumstick.png")
    drumstick_hit_image = Gosu::Image.new("media/drumstick_hit.png")
    #the image glows if the drum is being hit
    if game_data.space_released
        drumstick_image.draw(40, 0, ZOrder::FRONT, scale_x = 0.5, scale_y = 0.5)
    else
        drumstick_hit_image.draw(40, 0, ZOrder::FRONT, scale_x = 0.5, scale_y = 0.5)
    end
    #draw the points display
    @font.draw_text("#{game_data.score} points", 100, 40, ZOrder::FRONT, scale_x = 2, scale_y = 2, color = Gosu::Color::WHITE)
    #draw the buttons
    restart_button = Button.new(300, 400, 150, 40, "restart", 2, :go_to_game, game_data)
    draw_button(restart_button)
    exit_button = Button.new(520, 400, 80, 40, "exit", 2, :go_to_title, game_data)
    draw_button(exit_button)
    #gosu has a default framerate of 60fps, the window is 640 pixels wide
    #frames per beat = fps * 60 (since there are 60 seconds in a minute) / beats per minute
    #pixels needed to move is window width / frames per beat
    frames_per_beat = 3600.0 / game_data.bpm.to_f()
    speed = (self.width.to_f() - 125) / frames_per_beat.to_f()

    #loop through every beat and move it left at the correct speed
    count = game_data.beats.size()
    index = 0
    while (index < count)
        game_data.beats[index].x = game_data.beats[index].index * speed * frames_per_beat
        if (game_data.beats[index].hit)
            #change the colour from orange to green if the beat was scored successfully
            if (game_data.beats[index].scored)
                note_hit_image.draw(game_data.beats[index].x + game_data.x_offset, game_data.beats[index].y, ZOrder::FRONT)
            else
                note_not_hit_image.draw(game_data.beats[index].x + game_data.x_offset, game_data.beats[index].y, ZOrder::FRONT)
            end
        end
        #check if points need to be added or deducted
        if (game_data.beats[index].x + game_data.x_offset < 150 && !game_data.space_released)
            #if the beat hasnt scored points yet and it should be hit, add points based on how closely timed the players hit was
            if (game_data.beats[index].hit)
                if (!(game_data.beats[index].scored))
                    game_data.score += (10000 / (game_data.beats[index].x + game_data.x_offset - 150).abs()).round()
                end
                game_data.beats[index].scored = true
            else
                #subtract 200 points if the player wasnt meant to hit
                if (!game_data.beats[index].scored)
                    game_data.score -= 200
                    game_data.beats[index].scored = true
                end
            end
        end
        #prevents the player from scoring points for beats off the screen
        if (game_data.beats[index].x + game_data.x_offset + note_hit_image.width < 0)
            game_data.beats[index].scored = true
        end
        index += 1
    end
    game_data.x_offset -= speed
    game_data.frame += 1
    
    #if the final beat his been reached, stop the music
    if (game_data.frame > frames_per_beat * game_data.beats.size())
        game_data.audio_file.stop()
    end
    #wait a little bit after the final beat and take the player to the scoreboard
    if (game_data.frame -  120> frames_per_beat * game_data.beats.size())
        go_to_scoreboard(game_data)
    end

    #put a cool down on how often space can be pressed
    if (game_data.hit_timer < 60 && !game_data.space_released)
        game_data.hit_timer += 1
    end
    
    if (game_data.hit_timer = 60)
        game_data.space_released = true
    end

    return game_data
end

#function directs users to the game
def go_to_game(game_data)
    game_data.audio_file.stop()
    game_data.audio_file.play()
    count = game_data.beats.size()
    index = 0
    while (index < count)
        game_data.beats[index].scored = false
        index += 1
    end
    game_data.x_offset = game_data.beats.size() * 80 + 50
    game_data.frame = 0
    game_data.score = 0
    game_data.current_screen = Menu::GAME
    return game_data
end