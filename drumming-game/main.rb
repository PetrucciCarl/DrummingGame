require "gosu"
require "tk"
require "unimidi"
require "thread"
require_relative "ui"
require_relative "title"
require_relative "level-designer"
require_relative "game"
require_relative "scoreboard"

#this constant value is the standard midi note number for snare drums (or at least it is the number which works with my drum kit)
SNARE_NOTE = 38

module Menu
    TITLE, LEVEL_DESIGNER, GAME, SCOREBOARD = *0..3
end

module ZOrder
    BACK, MIDDLE, FRONT = *0..2
end

#I made this function since there is no inbuilt to_b function in ruby
def to_b(string)
    if string == "true"
        return true
    else
        return false
    end
end

#I made this class so that variables can be passed between functions easily
class GameData
    attr_accessor :beats, :mouse_released, :space_released, :x_offset, :bpm, :execute, :current_screen, :highscores, :audio_path, :audio_file, :bpm_box, :score, :frame, :testing, :test_frame, :test_index, :level_path, :hit_timer
end

#create a class called 'GameWindow' which inherits from gosu's window class
class GameWindow < Gosu::Window
    def initialize()
        #sets window dimensions by calling the parent initialize method from gosu's window class
        super 640, 480
        #sets window title
        self.caption = "Drumming Game"
        #adds a font to reference
        @font = Gosu::Font.new(18, name: "media/White On Black.ttf")

        @game_data = GameData.new()
        #setting default values for variables which will be used later
        @game_data.beats = [Beat.new(0, 0, false), Beat.new(80, 1, false), Beat.new(160, 2, false), Beat.new(240, 3, false), Beat.new(320, 4, false), Beat.new(400, 5, false), Beat.new(480, 6, false), Beat.new(560, 7, false),]
        @game_data.mouse_released = true
        @game_data.space_released = true
        @game_data.x_offset = 0
        @game_data.bpm = 60
        @game_data.execute = true
        @game_data.current_screen = Menu::TITLE
        @game_data.hit_timer = 0

        #a queue is a data structure (simmilar to a stack) which can be used to share data between threads
        @queue = Queue.new()
        #this function infinitely checks for when the snare drum is hit
        check_for_hit()
    end

    #the following function notifies the game when the snare drum is hit by pushing data to the queue
    def check_for_hit()
        begin
            #this code sets the drum input to be the first midi input device which is detected by the computer
            input = UniMIDI::Input.first
            #all of the code for checking for when the snare drum is hit needs to be running on a seperate thread since unimidi stalls the program until input is recieved
            Thread.new() do
                #the code runs in an infinite loop since I always want to be checking if the drum is hit
                while true
                    messages = input.gets()
                    #this code only runs if messages is valid
                    if messages
                        count = messages.size()
                        index = 0
                        #loop through every message recieved
                        while index < count
                            #check that the data is in the expected format (a hash containing a data key which stores an array of values)
                            if messages[index].is_a?(Hash) && messages[index][:data].is_a?(Array)
                                #assign each important value to a variable
                                data_array = messages[index][:data]
                                note = data_array[1]
                                velocity = data_array[2]
                                if note == SNARE_NOTE && velocity > 63
                                    @queue << :hit_drum
                                end
                            end
                            index += 1
                        end
                    end
                end
            end
        #this line allows the drum input code to be ignored if there is no input device detected
        rescue NoMethodError
        end
    end

    #logic for what to do once the snare drum has been hit here
    def update()
        while @queue.size() > 0
            event = @queue.pop(true)
            if event == :hit_drum
                @game_data.space_released = false
            end
        end
    end

    #drawing code here
    def draw()
        if (@game_data.current_screen == 0)
            @game_data = draw_title(@game_data)
        end
        if (@game_data.current_screen == 1)
            @game_data = draw_level_designer(@game_data)
        end
        if (@game_data.current_screen == 2)
            @game_data = draw_game(@game_data)
        end
        if (@game_data.current_screen == 3)
            @game_data = draw_scoreboard(@game_data)
        end
    end

    def button_down(id)
        #close game is esc is pressed
        if id == Gosu::KB_ESCAPE
            close()
        end
        #check if button is clicked
        if id == Gosu::MS_LEFT
            #make an array with each instance of a button object as an element
            buttons = ObjectSpace.each_object(Button).to_a()
            #loop through and check if each button is hovered
            count = buttons.size()
            index = 0
            while (index < count)
                if (ui_hovered(buttons[index]))
                    call_command(buttons[index], @game_data)
                end
                index += 1
            end
            #loop through each beat and toggle if it needs to be hit when it is clicked
            count = @game_data.beats.size()
            index = 0
            while (index < count)
                @game_data.beats[index].x += @game_data.x_offset
                if ui_hovered(@game_data.beats[index]) && @game_data.current_screen == Menu::LEVEL_DESIGNER
                    if @game_data.beats[index].hit
                        @game_data.beats[index].hit = false
                    else
                        @game_data.beats[index].hit = true
                    end
                end
                @game_data.beats[index].x -= @game_data.x_offset
                index += 1
            end
            @game_data.mouse_released = false
        end
        #if the scroll wheel is flicked up, either move the beats to the right or increase the bpm (depends on the mouse possition)
        if id == Gosu::MS_WHEEL_UP && @game_data.current_screen == Menu::LEVEL_DESIGNER
            if ui_hovered(@game_data.bpm_box) && @game_data.current_screen == @game_data.bpm_box.screen
                if @game_data.bpm < 240
                    @game_data.bpm += 1
                end
            else
                if @game_data.x_offset <= 0 && @game_data.current_screen == Menu::LEVEL_DESIGNER
                    @game_data.x_offset += 20
                end
            end
        end
        #if the scroll wheel is flicked down, either move the beats to the left or decrease the bpm (depends on the mouse possition)
        if id == Gosu::MS_WHEEL_DOWN && @game_data.current_screen == Menu::LEVEL_DESIGNER
            if ui_hovered(@game_data.bpm_box) && @game_data.current_screen == @game_data.bpm_box.screen
                if @game_data.bpm > 1
                    @game_data.bpm -= 1
                end
            else
                if @game_data.current_screen == Menu::LEVEL_DESIGNER
                    @game_data.x_offset -= 20
                end
            end
        end
        #changes to the glowing drumstick image when the spacebar is pressed
        if id == Gosu::KB_SPACE
            @game_data.space_released = false
            @game_data.hit_timer = 0
        end
    end

    def button_up(id)
        #this code is here to prevent more than 1 beat at a time being added when the add button is clicked
        if id == Gosu::MS_LEFT
            @game_data.mouse_released = true
        end
        #this code makes the drumstick image draw normally
        if id == Gosu::KB_SPACE
            @game_data.space_released = true
        end
    end
end
def main()
    #name the tk window (which will show up anyway when I call the file dialogue function)
    root = TkRoot.new()
    #hide the root window (since it is not needed)
    root.withdraw()
    window = GameWindow.new()
    window.show()
end

main()