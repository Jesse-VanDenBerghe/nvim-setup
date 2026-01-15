return {
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			local header = {
				[[                                                                                                                                                                                                      ]],
				[[88888888ba                                                                 88                                                                                                                         ]],
				[[88      "8b                                                         ,d     88                                                                                                                         ]],
				[[88      ,8P                                                         88     88                                                                                                                         ]],
				[[88aaaaaa8P'  8b,dPPYba,   ,adPPYba,   8b       d8   ,adPPYba,     MM88MMM  88,dPPYba,    ,adPPYba,  88,dPYba,,adPYba,      8b      db      d8  8b,dPPYba,   ,adPPYba,   8b,dPPYba,    ,adPPYb,d8      ]],
				[[88""""""'    88P'   "Y8  a8"     "8a  `8b     d8'  a8P_____88       88     88P'    "8a  a8P_____88  88P'   "88"    "8a     `8b    d88b    d8'  88P'   "Y8  a8"     "8a  88P'   `"8a  a8"    `Y88      ]],
				[[88           88          8b       d8   `8b   d8'   8PP"""""""       88     88       88  8PP"""""""  88      88      88      `8b  d8'`8b  d8'   88          8b       d8  88       88  8b       88      ]],
				[[88           88          "8a,   ,a8"    `8b,d8'    "8b,   ,aa       88,    88       88  "8b,   ,aa  88      88      88       `8bd8'  `8bd8'    88          "8a,   ,a8"  88       88  "8a,   ,d88  888 ]],
				[[88           88           `"YbbdP"'       "8"       `"Ybbd8"'       "Y888  88       88   `"Ybbd8"'  88      88      88         YP      YP      88           `"YbbdP"'   88       88   `"YbbdP"Y8  888 ]],
				[[                                                                                                                                                                                      aa,    ,88      ]],
				[[                                                                                                                                                                                       "Y8bbdP        ]],
			}

			local elixir_header = {
				[[                           ====                             ]],
				[[                         %*====                             ]],
				[[                       %%%*====                             ]],
				[[                     +#%%%*=+++                             ]],
				[[                    =*%%%%#*+++*                            ]],
				[[                   -+%%%%%%*++++                            ]],
				[[                  -=%%%%%%##*++++                           ]],
				[[                 --#%%%%%%###+++=                           ]],
				[[                --*%%%%%%%####+===                          ]],
				[[               -:=%%%%%%%%#####*===                         ]],
				[[              =:-#%%%%%%%%#%#####+==-                       ]],
				[[             ==:=%%%%%%%%%%#######*+=-                      ]],
				[[            =+=:*%%##%%%%###########+:.:                    ]],
				[[           =++=-%%%###%%#############*=:.                   ]],
				[[           +++==%%%%##%######**######**+-:                  ]],
				[[          ++++=*%%%%########*************+=                 ]],
				[[          +++++#%%%%%#####*******************               ]],
				[[         ++++++#%%%%%%###*************+++***##              ]],
				[[         ++++++*#%%%%%%##*************+++**####             ]],
				[[        #+++++***#%######****++++++++++++*######            ]],
				[[        #*+*******########*+++++++++++***#######            ]],
				[[        #**********########++++++++**###########*           ]],
				[[         +**********######***********##########*+           ]],
				[[         =+**********####*************########*==           ]],
				[[         ==+**************************######*=-=            ]],
				[[          ====+*****#*****************##*+=-----            ]],
				[[          -=======++====+++********+++=--------             ]],
				[[           -================+++++++++++==-----              ]],
				[[            =========-========+++++++++++++++               ]],
				[[              =======--------====++++++===++                ]],
				[[                ======---------====--==-==                  ]],
				[[                  -===:...:--===-::::::                     ]],
				[[                     :--------::.:..]],
			}

			local function footer()
				local datetime = os.date("%Y-%m-%d %H:%M:%S")
				local plugins_text = "⚡ Neovim loaded " .. datetime
				return plugins_text
			end

			local function buttons()
				local button_list = {
					dashboard.button("ldr ff", "Find file", ":Telescope find_files<CR>"),
					dashboard.button("ldr fo", "Recent files", ":Telescope oldfiles<CR>"),
					dashboard.button(":qa", "Quit Neovim", ":qa<CR>"),
				}
				return button_list
			end

			dashboard.section.header.val = elixir_header
			dashboard.section.buttons.val = buttons()
			dashboard.section.footer.val = footer()

			alpha.setup(dashboard.opts)
		end,
	},
}
