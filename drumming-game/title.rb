def draw_title(game_data)
    #draw background
    background_image = Gosu::Image.new("media/background1.png")
    background_image.draw(0, 0, ZOrder::BACK)
    #draw the title
    @font.draw_text("Drumming Game", 125, 100, ZOrder::MIDDLE, scale_x = 3, scale_y = 3, colour = Gosu::Color::WHITE)
    #draw the buttons
    play_button = Button.new(100, 400, 80, 40, "play", 0, :go_to_level_select, game_data)
    draw_button(play_button)
    create_button = Button.new(450, 400, 125, 40, "create", 0, :go_to_file_select, game_data)
    draw_button(create_button)
    #this variable is only here to prevent the file dialogue from opening repeatedly when the user closes it
    if (!game_data.execute)
        game_data.execute = true
    end
    return game_data
end

#function opens a file dialogue and allows the user to pick a level to play
def go_to_level_select(game_data)
    if game_data.execute
        game_data.level_path = Tk.getOpenFile(initialdir: "levels")
        game_data.execute = false
        #read values from the level file
        if game_data.level_path != ""
            level_file = File.new(game_data.level_path, "r")
            game_data.bpm = level_file.gets.to_i()
            game_data.audio_path = level_file.gets.chomp()
            game_data.audio_file = Gosu::Song.new(game_data.audio_path)
            game_data.highscores = Array.new()
            game_data.highscores << level_file.gets.to_i()
            game_data.highscores << level_file.gets.to_i()
            game_data.highscores << level_file.gets.to_i()
            game_data.beats = Array.new()
            count = level_file.gets.to_i()
            index = 0
            while(index < count)
                game_data.beats << Beat.new(0, index, to_b(level_file.gets.chomp()))
                index += 1
            end
            level_file.close()
            go_to_game(game_data)
        end
    else
        go_to_title(game_data)
    end
    return game_data
end

#function opens a file dialogue which the player can pick an audio file from for their level
def go_to_file_select(game_data)
    if game_data.execute
        game_data.execute = false
        #this code ensures only audio files can be selected
        file_types = [["Audio Files", [".wav", ".ogg", ".mp3"]]]
        game_data.audio_path = Tk.getOpenFile(filetypes: file_types)
        if game_data.audio_path != ""
            game_data.audio_file = Gosu::Song.new(game_data.audio_path)
            go_to_level_designer(game_data)
        end
    else
        go_to_title(game_data)
    end
    return game_data
end

#function directs user to title screen
def go_to_title(game_data)
    game_data.audio_file.stop()
    game_data.bpm = 60
    game_data.beats = [Beat.new(0, 0, false), Beat.new(80, 1, false), Beat.new(160, 2, false), Beat.new(240, 3, false), Beat.new(320, 4, false), Beat.new(400, 5, false), Beat.new(480, 6, false), Beat.new(560, 7, false),]
    game_data.current_screen = Menu::TITLE
    return game_data
end