def ui_hovered(ui)
    #checking if mouse is in the same location as ui pixels
    if ((mouse_x >= ui.x && mouse_x <= ui.x + ui.w) && (mouse_y >= ui.y && mouse_y <= ui.y + ui.h))
        return true
    else
        return false
    end
end


#record stores basic information to create any type of button
class Button
    attr_accessor :x, :y, :w, :h, :text, :text_offset, :command, :screen
    def initialize(x, y, w, h, text, text_offset, command, game_data)
        @x = x
        @y = y
        @w = w
        @h = h
        @text = text
        @text_offset = text_offset
        #to add a function as a parameter, write :function_name
        @command = method(command)
        #set current screen upon initialize, so that invisible button cannot be pressed in different menu
        @screen = game_data.current_screen
    end
end

def draw_button(button)
    #change how the button is drawn based on if it is hovered over or not
    if (ui_hovered(button))
        @font.draw_text(button.text, button.x + button.text_offset, button.y, ZOrder::FRONT, scale_x = button.h / 18, button.h / 18, color = Gosu::Color.argb(0xffffaa00))
    else
        @font.draw_text(button.text, button.x + button.text_offset, button.y, ZOrder::FRONT, scale_x = button.h / 18, button.h / 18, color = Gosu::Color::BLACK)
    end
end

def call_command(button, game_data)
    #check that user is in correct menu
    if (game_data.current_screen == button.screen)
        #calls the function which is specified in the command parameter
        button.command.call(game_data)
    end
end

#this record just groups together some basic data about the beats so that they can be used in different menus
class Beat
    attr_accessor :x, :y, :w, :h, :hit, :index, :scored
     def initialize(x, index, hit)
        @x = x
        @y = 100
        @w = 50
        @h = 200
        @hit = hit
        @index = index
        @scored = false
     end
end

#I made this record for detecting ui hovers for non-buttons, but only ended up using it for changing the bpm
class BoxCollision
    attr_accessor :x, :y, :w, :h, :screen
    def initialize(x, y, w, h, game_data)
        @x = x
        @y = y
        @w = w
        @h = h
        @screen = game_data.current_screen
    end
end