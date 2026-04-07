def draw_scoreboard(game_data)
    #draw background
    background_image = Gosu::Image.new("media/background0.png")
    background_image.draw(0, 0, ZOrder::BACK)
    #draw the text
    @font.draw_text("You scored:", 180, 30, ZOrder::MIDDLE, scale_x = 3, scale_y = 3, colour = Gosu::Color::WHITE)
    @font.draw_text(game_data.score, 180, 100, ZOrder::MIDDLE, scale_x = 2, scale_y = 2, colour = Gosu::Color::WHITE)
    @font.draw_text("Top three best scores:", 0, 200, ZOrder::MIDDLE, scale_x = 3, scale_y = 3, colour = Gosu::Color::WHITE)
    @font.draw_text(game_data.highscores[0], 180, 270, ZOrder::MIDDLE, scale_x = 2, scale_y = 2, colour = Gosu::Color::WHITE)
    @font.draw_text(game_data.highscores[1], 180, 310, ZOrder::MIDDLE, scale_x = 2, scale_y = 2, colour = Gosu::Color::WHITE)
    @font.draw_text(game_data.highscores[2], 180, 350, ZOrder::MIDDLE, scale_x = 2, scale_y = 2, colour = Gosu::Color::WHITE)

    #draw the button to return to the main menu
    menu_button = Button.new(30, 400, 100, 40, "menu", 10, :go_to_title, game_data)
    draw_button(menu_button)
    return game_data
end

#function directs users to the scoreboard
def go_to_scoreboard(game_data)
    #get the top 3 high scores and save them to the file
    game_data.highscores << game_data.score
    game_data.highscores = game_data.highscores.sort.reverse()
    save_file = File.new(game_data.level_path, "w")
    save_file.puts(game_data.bpm)
    save_file.puts(game_data.audio_path)
    save_file.puts(game_data.highscores[0])
    save_file.puts(game_data.highscores[1])
    save_file.puts(game_data.highscores[2])
    save_file.puts(game_data.beats.size())
    count = game_data.beats.size()
    index = 0
    while (index < count)
        save_file.puts(game_data.beats[index].hit)
        index += 1
    end
    save_file.close()
    game_data.current_screen = Menu::SCOREBOARD
    return game_data
end