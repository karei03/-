module Toufu
using Gtk4, Printf

function julia_main()::Cint
    println("程序启动, 请稍候...")
    win = GtkWindow("秋名山豆腐店v1.1", 600, 440)
    win[] = paned = GtkPaned(:v)
    paned.position = 70

    # 左侧统计信息栏
    statsBox = GtkBox(:v)
    statsBox.valign = Gtk4.Align(3)
    statsBox.vexpand = true
    paned[1] = statsBox

    # 右侧选项卡
    paned[2] = notebook = GtkNotebook()

    # 显示豆腐块数和生产速度的标签
    toulable = GtkLabel("0 块豆腐")
    toulable.halign = Gtk4.Align(2)
    toulable.margin_start = 20
    toulable.margin_end = 20
    push!(statsBox, toulable)

    dratelabel = GtkLabel("0 块豆腐/s")
    dratelabel.halign = Gtk4.Align(2)
    dratelabel.margin_start = 20
    dratelabel.margin_end = 20
    push!(statsBox, dratelabel)

    # 创建滚动窗口和按钮列表
    scrolled_window = GtkScrolledWindow()
    scrolled_window[] = list_box = GtkGrid()
    push!(notebook, scrolled_window, "　购车　")

    # 计数器变量
    counter = 0.0
    car_rate = 0.0  # 每秒增加的值
    manual_rate = 1.0

    # 手动送豆腐按钮
    car0 = GtkButton("Click")
    car0.height_request = 50
    list_box[2:3, 1] = car0
    carlabel = GtkLabel("手动送豆腐")
    carlabel.halign = Gtk4.Align(1)
    Gtk4.markup(carlabel, "手动送豆腐")
    list_box[1, 1] = carlabel

    # 手动送豆腐按钮的点击事件
    on_manual_delivery(_) = (counter += manual_rate)
    signal_connect(on_manual_delivery, car0, "clicked")

    # 初始化车车信息
    num_cars = 9
    car_levels = zeros(Int, num_cars)  # 每辆车的初始等级为0
    # 车的初始价格
    base_prices = [round(Int, 9.8^i) for i in 1:num_cars]
    # 每辆车的基础生产速度
    base_rates = [7 .^ (0:num_cars-1);]
    # 每辆车的当前生产速度
    car_rates(i) = round(Int, 2^(car_levels[i] ÷ 20 + 1) * car_levels[i]^1.2 * base_rates[i])
    # 下一级的生产速度
    car_rates_next(i) = round(Int, 2^((car_levels[i] + 1) ÷ 20 + 1) * (car_levels[i] + 1)^1.2 * base_rates[i])
    # 当前车的升级价格
    car_price(i, lv) = round(Int, 8^(lv ÷ 20) * 2(lv + 1) * base_prices[i])
    function fx10price(f::Function, i::Int, lvᵢ::Int)
        sum = 0.0
        for j = 1:10
            sum += f(i, lvᵢ + j - 1)
        end
        return sum
    end
    cars = []  # 存放车车按钮
    car_buttons = []
    car_buttons10 = []

    # 第二个选项卡
    scrolled_window2 = GtkScrolledWindow()
    scrolled_window2[] = list_box2 = GtkGrid()
    push!(notebook, scrolled_window2, "点击强化")
    tab2_label, tab2_button, tab2_button_x10 = [], [], []

    # 第三个选项卡
    scrolled_window3 = GtkScrolledWindow()
    scrolled_window3[] = list_box3 = GtkGrid()
    push!(notebook, scrolled_window3, "车辆强化")
    tab3_label, tab3_button = [], []

    # 第四个选项卡
    scrolled_window4 = GtkScrolledWindow()
    scrolled_window4[] = list_box4 = GtkGrid()
    push!(notebook, scrolled_window4, "　xx　")
    tab4_label, tab4_button = [], []

    # 第五个选项卡
    scrolled_window5 = GtkScrolledWindow()
    scrolled_window5[] = list_box5 = GtkGrid()
    push!(notebook, scrolled_window5, "　xx　")
    tab5_label, tab5_button = [], []

    car_name = ["RPS13", "NA6CE", "AP1", "DC2", "EK9", "NB8C", "GR9", "ZZW30", "AE86", "EA11R"]
    # 创建车车按钮
    for i in 1:num_cars
        car_label = GtkLabel(car_name[i] * " Lv. 0")
        car_label.halign = Gtk4.Align(1)
        # Gtk4.markup(car0label, "<b>My bold text</b>")
        list_box[1, i+1] = car_label

        car_button = GtkButton("Lv+1")
        car_button.height_request = 50
        list_box[2, i+1] = car_button

        car_button10 = GtkButton("Lv+10")
        car_button10.height_request = 50
        list_box[3, i+1] = car_button10
        push!(cars, car_label)
        push!(car_buttons, car_button)
        push!(car_buttons10, car_button10)
    end

    # 点击强化选项
    tab2len = 1
    list_box2[1, 1] = label2 = GtkLabel("手速强化")
    label2.halign = Gtk4.Align(1)

    list_box2[2, 1] = button2 = GtkButton("Lv+1")
    button2.height_request = 50
    tab2lv = zeros(Int, tab2len)
    tab2_1_speed(i) = round(Int, 2^(tab2lv[i] ÷ 10) * 7^tab2lv[i])
    base2_1_price = [66]
    tab2_1_price(i, lv) = (9.2^lv + lv^8) * base2_1_price[i]

    list_box2[3, 1] = button2x10 = GtkButton("Lv+10")
    button2x10.height_request = 50
    push!(tab2_label, label2)
    push!(tab2_button, button2)
    push!(tab2_button_x10, button2x10)

    # 更新按钮状态的函数
    function update_button_states()
        for i in 1:num_cars
            x1price = car_price(i, car_levels[i])
            x10price = fx10price(car_price, i, car_levels[i])
            car_buttons[i].sensitive = counter >= x1price
            car_buttons10[i].sensitive = counter >= x10price
            # 更新车车按钮的显示文本，包含当前等级和价格
            if i == 5
                color = "'green'"
            elseif i == 9
                color = "'red'"
            else
                color = "'black'"
            end
            Gtk4.markup(cars[i], "<span foreground=" * color * ">" * car_name[i] * " Lv. $(car_levels[i]) | $(car_rates(i)) 块豆腐/s 下一级+$(car_rates_next(i)-car_rates(i))</span>")
            car_buttons[i].label = "Lv+1\n-" * @sprintf("%.3g", x1price) * " 豆腐"
            car_buttons10[i].label = "Lv+10\n-" * @sprintf("%.3g", x10price) * " 豆腐"

            if i <= tab2len
                x1price = tab2_1_price(i, tab2lv[i])
                x10price = fx10price(tab2_1_price, i, tab2lv[i])
                tab2_button[i].sensitive = counter >= x1price
                tab2_button_x10[i].sensitive = counter >= x10price
                Gtk4.markup(tab2_label[i], "<span foreground='#00008B'>手速强化 $i Lv. $(tab2lv[i]) | $(tab2_1_speed(i)) 块豆腐/s 下一级+ ???       </span>")
                tab2_button[i].label = "Lv+1\n-" * @sprintf("%.3g", x1price) * " 豆腐"
                tab2_button_x10[i].label = "Lv+10\n-" * @sprintf("%.3g", x10price) * " 豆腐"
            end
        end
    end

    # 每个车车按钮的点击事件
    for i in 1:num_cars
        function on_car_click(widget)
            x1price = car_price(i, car_levels[i])
            if counter >= x1price
                counter -= x1price  # 减去车车的价格
                car_levels[i] += 1  # 提升车车的等级
                car_rate = sum([car_rates(i) for i in 1:num_cars])  # 更新车车的生产速度
                dratelabel.label = string(round(Int64, car_rate), " 块豆腐/s")
            end
        end
        signal_connect(on_car_click, car_buttons[i], "clicked")

        function on_car_click_x10(widget)
            x10price = fx10price(car_price, i, car_levels[i])
            if counter >= x10price
                counter -= x10price  # 减去车车的价格
                car_levels[i] += 10  # 提升车车的等级
                car_rate = sum([car_rates(i) for i in 1:num_cars])  # 更新车车的生产速度
                dratelabel.label = string(round(Int64, car_rate), " 块豆腐/s")
            end
        end
        signal_connect(on_car_click_x10, car_buttons10[i], "clicked")

        if i <= tab2len
            function on_tab2_1_click(widget)
                x1price = tab2_1_price(i, tab2lv[i])
                if counter >= x1price
                    counter -= x1price  # 减去车车的价格
                    tab2lv[i] += 1  # 提升车车的等级
                    manual_rate = sum([tab2_1_speed(i) for i in 1:tab2len])  # 更新车车的生产速度
                end
            end
            signal_connect(on_tab2_1_click, tab2_button[i], "clicked")

            function on_tab2_1_click_x10(widget)
                x10price = fx10price(tab2_1_price, i, tab2lv[i])
                if counter >= x10price
                    counter -= x10price  # 减去车车的价格
                    tab2lv[i] += 10  # 提升车车的等级
                    manual_rate = sum([tab2_1_speed(i) for i in 1:tab2len])  # 更新车车的生产速度
                end
            end
            signal_connect(on_tab2_1_click_x10, tab2_button_x10[i], "clicked")
        end
    end

    # 更新计数器的函数，每秒增加drate的值
    function update_counter()
        counter += 0.1 * car_rate
        Gtk4.markup(toulable, "<span font='14'>" * string(round(Int64, counter), " 块豆腐") * "</span>")
        update_button_states()  # 刷新按钮激活状态
        return true  # 返回 true 以保持循环
    end

    g_timeout_add(update_counter, 100) # 每0.1秒更新一次计数器
    show(win)

    if !isinteractive()
        @async Gtk4.GLib.glib_main()
        Gtk4.GLib.waitforsignal(win, :close_request)
    end
    return 0
end
end
