# Inspired by https://github.com/RailsApps/rails-composer/blob/master/composer.rb

# 1. Gems
# 2. Database
# 3. Devise
# 4. Procfile
# 5. Unicorn config file
# 6. Bootstrap
# 7. First Model & Scaffold
# 8. Server start.sh
# X. Migrate and start

# Step 1: Gems
gem 'pg'
gem 'devise'
gem 'unicorn'

gem 'debugger'
gem 'binding_of_caller'
gem 'better_errors'
gem 'quiet_assets'

gem 'haml'
gem 'haml-rails'

gem 'therubyracer'
gem 'less-rails'
gem 'twitter-bootstrap-rails'

gem 'jquery-rails'
gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'

# Step 2: Database
remove_file "config/database.yml"
create_file "config/database.yml" do
"development:
  adapter: postgresql
  database: #{app_name}_development
  pool: 5
  username: postgres
  password: 168washu

test:
  adapter: postgresql
  database: #{app_name}_development
  pool: 5
  username: postgres
  password: 168washu

production:
  adapter: postgresql
  database: db/production.postgresql
  pool: 5"
end

# Step 3: Devise
run 'rake db:drop'
run 'rake db:create'

generate 'devise:install'
generate 'devise user'

# Step 4: Procfile
create_file "Procfile" do
  "web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb"
end

# Step 5: Unicorn file
create_file "config/unicorn.rb" do
"
# config/unicorn.rb

worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout Integer(ENV['WEB_TIMEOUT'] || 20)
preload_app true

if ENV['RAILS_ENV'] == 'development'
  listen 3000
end

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end  

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
"
end

# Step 6: Bootstrap
generate "bootstrap:install less"

remove_file "app/views/layouts/application.html.erb"
generate "bootstrap:layout application fluid"

# Step 7: First Model
if yes? "Do you want to generate a model?"
  args = ask("supply migration arguments:")
  model_name = args.split[0]
  controller_name = model_name + "s"
  generate "scaffold #{args} --skip-fixture"
  run 'rake db:migrate'
  generate "bootstrap:themed #{controller_name} -f"
  
  append_file "app/assets/stylesheets/bootstrap_and_overrides.css.less" do
%Q[
  // Your custom LESS stylesheets goes here
  //
  // Since bootstrap was imported above you have access to its mixins which
  // you may use and inherit here
  //
  // If you'd like to override bootstrap's own variables, you can do so here as well
  // See http://twitter.github.com/bootstrap/customize.html#variables for their names and documentation
  //
  // Example:
  // @linkColor: #ff0000;

  // Cosmo 2.3.1
  // Variables
  // --------------------------------------------------


  // Global values
  // --------------------------------------------------


  // Grays
  // -------------------------
  @black:                 #000;
  @grayDarker:            #080808;
  @grayDark:              #999;
  @gray:                  #bbb;
  @grayLight:             #dfdfdf;
  @grayLighter:           #eee;
  @white:                 #fff;


  // Accent colors
  // -------------------------
  @blue:                  #007FFF;
  @blueDark:              #1F26B6;
  @green:                 #3FB618;
  @red:                   #FF0039;
  @yellow:                #FFA500;
  @orange:                #FF7518;
  @pink:                  #E671B8;
  @purple:                #9954BB;


  // Scaffolding
  // -------------------------
  @bodyBackground:        @white;
  @textColor:             #555;


  // Links
  // -------------------------
  @linkColor:             @blue;
  @linkColorHover:        darken(@linkColor, 10%);


  // Typography
  // -------------------------
  @sansFontFamily:        "Open Sans", Calibri, Candara, Arial, sans-serif;
  @serifFontFamily:       Georgia, "Times New Roman", Times, serif;
  @monoFontFamily:        Monaco, Menlo, Consolas, "Courier New", monospace;

  @baseFontSize:          14px;
  @baseFontFamily:        @sansFontFamily;
  @baseLineHeight:        20px;
  @altFontFamily:         @serifFontFamily;

  @headingsFontFamily:    inherit; // empty to use BS default, @baseFontFamily
  @headingsFontWeight:    300;    // instead of browser default, bold
  @headingsColor:         @grayDarker; // empty to use BS default, @textColor


  // Component sizing
  // -------------------------
  // Based on 14px font-size and 20px line-height

  @fontSizeLarge:         @baseFontSize * 1.25; // ~18px
  @fontSizeSmall:         @baseFontSize * 0.85; // ~12px
  @fontSizeMini:          @baseFontSize * 0.75; // ~11px

  @paddingLarge:          22px 30px; // 66px
  @paddingSmall:          2px 10px;  // 26px
  @paddingMini:           2px 6px;   // 24px

  @baseBorderRadius:      0px;
  @borderRadiusLarge:     0px;
  @borderRadiusSmall:     0px;


  // Tables
  // -------------------------
  @tableBackground:                   transparent; // overall background-color
  @tableBackgroundAccent:             #f9f9f9; // for striping
  @tableBackgroundHover:              #E8F8FD; // for hover
  @tableBorder:                       #ddd; // table and cell border

  // Buttons
  // -------------------------
  @btnBackground:                     @grayLighter;
  @btnBackgroundHighlight:            darken(@grayLighter, 15%);
  @btnBorder:                         #bbb;

  @btnPrimaryBackground:              lighten(@blue, 5%);
  @btnPrimaryBackgroundHighlight:     darken(@blue, 5%);

  @btnInfoBackground:                 lighten(@purple, 5%);
  @btnInfoBackgroundHighlight:        darken(@purple, 5%);

  @btnSuccessBackground:              lighten(@green, 5%);
  @btnSuccessBackgroundHighlight:     darken(@green, 5%);

  @btnWarningBackground:              lighten(@orange, 5%);
  @btnWarningBackgroundHighlight:     darken(@orange, 5%);

  @btnDangerBackground:               lighten(@red, 5%);
  @btnDangerBackgroundHighlight:      darken(@red, 5%);

  @btnInverseBackground:              lighten(@black, 5%);
  @btnInverseBackgroundHighlight:     darken(@black, 5%);


  // Forms
  // -------------------------
  @inputBackground:               @white;
  @inputBorder:                   @gray;
  @inputBorderRadius:             @baseBorderRadius;
  @inputDisabledBackground:       @grayLighter;
  @formActionsBackground:         #f5f5f5;
  @inputHeight:                   @baseLineHeight + 10px; // base line-height + 8px vertical padding + 2px top/bottom border


  // Dropdowns
  // -------------------------
  @dropdownBackground:            @white;
  @dropdownBorder:                rgba(0,0,0,.2);
  @dropdownDividerTop:            #e5e5e5;
  @dropdownDividerBottom:         @white;

  @dropdownLinkColor:             @grayDark;
  @dropdownLinkColorHover:        @white;
  @dropdownLinkColorActive:       @white;

  @dropdownLinkBackgroundActive:  @blue;
  @dropdownLinkBackgroundHover:   @dropdownLinkBackgroundActive;



  // COMPONENT VARIABLES
  // --------------------------------------------------


  // Z-index master list
  // -------------------------
  // Used for a bird's eye view of components dependent on the z-axis
  // Try to avoid customizing these :)
  @zindexDropdown:          1000;
  @zindexPopover:           1010;
  @zindexTooltip:           1030;
  @zindexFixedNavbar:       1030;
  @zindexModalBackdrop:     1040;
  @zindexModal:             1050;


  // Sprite icons path
  // -------------------------
  @iconSpritePath:          "../img/glyphicons-halflings.png";
  @iconWhiteSpritePath:     "../img/glyphicons-halflings-white.png";


  // Input placeholder text color
  // -------------------------
  @placeholderText:         @gray;


  // Hr border color
  // -------------------------
  @hrBorder:                @grayLighter;


  // Horizontal forms & lists
  // -------------------------
  @horizontalComponentOffset:       180px;


  // Wells
  // -------------------------
  @wellBackground:                  @grayLighter;


  // Navbar
  // -------------------------
  @navbarCollapseWidth:             979px;
  @navbarCollapseDesktopWidth:      @navbarCollapseWidth + 1;

  @navbarHeight:                    50px;
  @navbarBackgroundHighlight:       @grayDarker;
  @navbarBackground:                @grayDarker;
  @navbarBorder:                    transparent;

  @navbarText:                      @white;
  @navbarLinkColor:                 @white;
  @navbarLinkColorHover:            @gray;
  @navbarLinkColorActive:           @white;
  @navbarLinkBackgroundHover:       rgba(0, 0, 0, 0.05);
  @navbarLinkBackgroundActive:      transparent;

  @navbarBrandColor:                @navbarLinkColor;

  // Inverted navbar
  @navbarInverseBackground:                @blue;
  @navbarInverseBackgroundHighlight:       @navbarInverseBackground;
  @navbarInverseBorder:                    transparent;

  @navbarInverseText:                      @white;
  @navbarInverseLinkColor:                 @white;
  @navbarInverseLinkColorHover:            @white;
  @navbarInverseLinkColorActive:           @navbarInverseLinkColorHover;
  @navbarInverseLinkBackgroundHover:       rgba(0, 0, 0, 0.05);
  @navbarInverseLinkBackgroundActive:      @navbarInverseBackground;

  @navbarInverseSearchBackground:          lighten(@navbarInverseBackground, 25%);
  @navbarInverseSearchBackgroundFocus:     @white;
  @navbarInverseSearchBorder:              @navbarInverseBackground;
  @navbarInverseSearchPlaceholderColor:    @grayDark;

  @navbarInverseBrandColor:                @navbarInverseLinkColor;


  // Pagination
  // -------------------------
  @paginationBackground:                @grayLight;
  @paginationBorder:                    transparent;
  @paginationActiveBackground:          @blue;


  // Hero unit
  // -------------------------
  @heroUnitBackground:              @grayLighter;
  @heroUnitHeadingColor:            inherit;
  @heroUnitLeadColor:               inherit;


  // Form states and alerts
  // -------------------------
  @warningText:             @white;
  @warningBackground:       @orange;
  @warningBorder:           transparent;

  @errorText:               @white;
  @errorBackground:         @red;
  @errorBorder:             transparent;

  @successText:             @white;
  @successBackground:       @green;
  @successBorder:           transparent;

  @infoText:                @white;
  @infoBackground:          @purple;
  @infoBorder:              transparent;


  // Tooltips and popovers
  // -------------------------
  @tooltipColor:            #fff;
  @tooltipBackground:       #000;
  @tooltipArrowWidth:       5px;
  @tooltipArrowColor:       @tooltipBackground;

  @popoverBackground:       @orange;
  @popoverArrowWidth:       15px;
  @popoverArrowColor:       @orange;
  @popoverTitleBackground:  @orange;

  // Special enhancement for popovers
  @popoverArrowOuterWidth:  @popoverArrowWidth + 1;
  @popoverArrowOuterColor:  transparent;



  // GRID
  // --------------------------------------------------


  // Default 940px grid
  // -------------------------
  @gridColumns:             12;
  @gridColumnWidth:         60px;
  @gridGutterWidth:         20px;
  @gridRowWidth:            (@gridColumns * @gridColumnWidth) + (@gridGutterWidth * (@gridColumns - 1));

  // 1200px min
  @gridColumnWidth1200:     70px;
  @gridGutterWidth1200:     30px;
  @gridRowWidth1200:        (@gridColumns * @gridColumnWidth1200) + (@gridGutterWidth1200 * (@gridColumns - 1));

  // 768px-979px
  @gridColumnWidth768:      42px;
  @gridGutterWidth768:      20px;
  @gridRowWidth768:         (@gridColumns * @gridColumnWidth768) + (@gridGutterWidth768 * (@gridColumns - 1));


  // Fluid grid
  // -------------------------
  @fluidGridColumnWidth:    percentage(@gridColumnWidth/@gridRowWidth);
  @fluidGridGutterWidth:    percentage(@gridGutterWidth/@gridRowWidth);

  // 1200px min
  @fluidGridColumnWidth1200:     percentage(@gridColumnWidth1200/@gridRowWidth1200);
  @fluidGridGutterWidth1200:     percentage(@gridGutterWidth1200/@gridRowWidth1200);

  // 768px-979px
  @fluidGridColumnWidth768:      percentage(@gridColumnWidth768/@gridRowWidth768);
  @fluidGridGutterWidth768:      percentage(@gridGutterWidth768/@gridRowWidth768);

  // Cosmo 2.3.1
  // Bootswatch
  // -----------------------------------------------------


  // TYPOGRAPHY
  // -----------------------------------------------------

  @import url('//fonts.googleapis.com/css?family=Open+Sans:400italic,700italic,400,700');

  body {
  	font-weight: 300;
  }

  h1 {
  	font-size: 50px;
  }

  h2, h3 {
  	font-size: 26px;
  }

  h4 {
  	font-size: 14px;
  }

  h5, h6 {
  	font-size: 11px;
  }

  blockquote {

  	padding: 10px 15px;
  	background-color: @grayLighter;
  	border-left-color: @gray;

  	&.pull-right {
  		padding: 10px 15px;
  		border-right-color: @gray;
  	}

  	small {
  		color: @gray;
  	}
  }

  .muted {
  	color: @gray;
  }

  .text-warning        { color: @orange; }
  a.text-warning:hover { color: darken(@orange, 10%); }

  .text-error          { color: @red; }
  a.text-error:hover   { color: darken(@red, 10%); }

  .text-info           { color: @purple; }
  a.text-info:hover    { color: darken(@purple, 10%); }

  .text-success        { color: @green; }
  a.text-success:hover { color: darken(@green, 10%); }

  // SCAFFOLDING
  // -----------------------------------------------------

  .float_right { float: right; }
  .float_left { float: left; }

  // NAVBAR
  // -----------------------------------------------------

  .navbar {

  	.navbar-inner {
  		background-image: none;
  		.box-shadow(none);
  		.border-radius(0);
  	}

  	.brand {

  		&:hover {
  			color: @navbarLinkColorHover;
  		}
  	}

  	.nav > .active > a,
  	.nav > .active > a:hover,
  	.nav > .active > a:focus {
  		.box-shadow(none);
  		background-color: @navbarLinkBackgroundHover;
  	}

  	.nav li.dropdown.open > .dropdown-toggle,
  	.nav li.dropdown.active > .dropdown-toggle,
  	.nav li.dropdown.open.active > .dropdown-toggle {
  		color: @white;

  		&:hover {
  			color: @grayLighter;
  		}
  	}

  	.navbar-search .search-query {
  		line-height: normal;
  	}

  	&-inverse {

  		.brand,
  		.nav > li > a {
  			text-shadow: none;
  		}

  		.brand:hover,
  		.nav > .active > a,
  		.nav > .active > a:hover,
  		.nav > .active > a:focus {
  			background-color: @navbarInverseLinkBackgroundHover;
  			.box-shadow(none);
  			color: @white;
  		}

  		.navbar-search .search-query {
  			color: @grayDarker;
  		}
  	}
  }

  div.subnav {

  	margin: 0 1px;
  	background: @grayLight none;
  	.box-shadow(none);
  	border: none;
  	.border-radius(0);

  	.nav {
  		background-color: transparent;
  	}

  	.nav > li > a {
  		border-color: transparent;
  	}

  	.nav > .active > a,
  	.nav > .active > a:hover {
  		border-color: transparent;
  		background-color: @black;
  		color: @white;
  		.box-shadow(none);
  	}

  	&-fixed {
  		top: @navbarHeight + 1;
  		margin: 0;
  	}
  }

  // NAV
  // -----------------------------------------------------

  .nav {

  	.open .dropdown-toggle,
  	& > li.dropdown.open.active > a:hover {
  		color: @blue;
  	}
  }

  .nav-tabs {

  	& > li > a {
  		.border-radius(0);
  	}

  	&.nav-stacked {

  		& > li > a:hover {
  			background-color: @blue;
  			color: @white;
  		}

  		& > .active > a,
  		& > .active > a:hover {
  			background-color: @white;
  			color: @gray;
  		}

  		& > li:first-child > a,
  		& > li:last-child > a {
  			.border-radius(0);
  		}
  	}
  }

  .tabs-below,
  .tabs-left,
  .tabs-right {

  	& > .nav-tabs > li > a{
  		.border-radius(0);
  	}
  }

  .nav-pills {

  	& > li > a {
  		background-color: @grayLight;
  		.border-radius(0);
  		color: @black;

  		&:hover {
  			background-color: @black;
  			color: @white;
  		}
  	}

  	& > .disabled > a,
  	& > .disabled > a:hover {
  		background-color: @grayLighter;
  		color: @grayDark;
  	}
  }

  .nav-list {

  	& > li > a {
  		color: @grayDarker;

  		&:hover {
  			background-color: @blue;
  			color: @white;
  			text-shadow: none;
  		}
  	}

  	.nav-header {
  		color: @grayDarker;
  	}

  	.divider {
  		background-color: @gray;
  		border-bottom: none;
  	}
  }

  .pagination {

  	ul {

  		.box-shadow(none);

  		& > li > a,
  		& > li > span {
  			margin-right: 6px;
  			color: @grayDarker;

  			&:hover {
  				background-color: @grayDarker;
  				color: @white;
  			}
  		}

  		& > li:last-child > a,
  		& > li:last-child > span {
  			margin-right: 0;
  		}

  		& > .active > a,
  		& > .active > span { 
  			color: @white;
  		}

  		& > .disabled > span,
  		& > .disabled > a,
  		& > .disabled > a:hover {
  			background-color: @grayLighter;
  			color: @grayDark;
  		}
  	}
  }

  .pager {

  	li > a,
  	li > span {
  		background-color: @grayLight;
  		border: none;
  		.border-radius(0);
  		color: @grayDarker;

  		&:hover {
  			background-color: @grayDarker;
  			color: @white;
  		}
  	}

  	.disabled > a,
  	.disabled > a:hover,
  	.disabled > span {
  		background-color: @grayLighter;
  		color: @grayDark;
  	}

  }

  .breadcrumb {
  	background-color: @grayLight;

  	li {
  		text-shadow: none;
  	}

  	.divider,
  	.active {
  		color: @grayDarker;
  		text-shadow: none;
  	}
  }

  // BUTTONS
  // -----------------------------------------------------

  .btn {
  	padding: 5px 12px;
  	background-image: none;
  	.box-shadow(none);
  	border: none;
  	.border-radius(0);
  	text-shadow: none;

  	&.disabled {
  		box-shadow: inset 0 2px 4px rgba(0,0,0,.15),~" "0 1px 2px rgba(0,0,0,.05);
  	}
  }

  .btn-large {
  	padding: 22px 30px;
  }

  .btn-small {
  	padding: 2px 10px;
  }

  .btn-mini {
  	padding: 2px 6px;
  }

  .btn-group {

  	& > .btn:first-child,
  	& > .btn:last-child,
  	& > .dropdown-toggle {
  		.border-radius(0);
  	}

  	& > .btn + .dropdown-toggle {
  		.box-shadow(none);
  	}
  }

  // TABLES
  // -----------------------------------------------------

  .table {

  	tbody tr.success td {
  		color: @white;
  	}

  	tbody tr.error td {
  		color: @white;
  	}

  	tbody tr.info td {
  		color: @white;
  	}

  	&-bordered {
  		.border-radius(0);

  		thead:first-child tr:first-child th:first-child,
  		tbody:first-child tr:first-child td:first-child {
  			.border-radius(0);
  		}

  		thead:last-child tr:last-child th:first-child,
  		tbody:last-child tr:last-child td:first-child,
  		tfoot:last-child tr:last-child td:first-child {
  			.border-radius(0);
  		}
  	}
  }

  // FORMS
  // -----------------------------------------------------

  select, textarea, input[type="text"], input[type="password"], input[type="datetime"],
  input[type="datetime-local"], input[type="date"], input[type="month"], input[type="time"],
  input[type="week"], input[type="number"], input[type="email"], input[type="url"],
  input[type="search"], input[type="tel"], input[type="color"] {
  	color: @grayDarker;
  }

  .control-group {

  	&.warning {

  		.control-label,
  		.help-block,
  		.help-inline {
  			color: @orange;
  		}

  		input,
  		select,
  		textarea {
  			border-color: @orange;
  			color: @grayDarker;
  		}
  	}

  	&.error {

  		.control-label,
  		.help-block,
  		.help-inline {
  			color: @red;
  		}

  		input,
  		select,
  		textarea {
  			border-color: @red;
  			color: @grayDarker;
  		}
  	}

  	&.success {

  		.control-label,
  		.help-block,
  		.help-inline {
  			color: @green;
  		}

  		input,
  		select,
  		textarea {
  			border-color: @green;
  			color: @grayDarker;
  		}
  	}
  }

  legend {
  	border-bottom: none;
  	color: @grayDarker;
  }

  .form-actions {
  	border-top: none;
  	background-color: @grayLighter;
  }

  // DROPDOWNS
  // -----------------------------------------------------

  .dropdown-menu {
  	.border-radius(0);
  }

  // ALERTS, LABELS, BADGES
  // -----------------------------------------------------

  .alert {
  	.border-radius(0);
  	text-shadow: none;

  	&-heading, h1, h2, h3, h4, h5, h6 {
  		color: @white;
  	}
  }

  .label {
  	min-width: 80px;
  	min-height: 80px;
  	.border-radius(0);
  	font-weight: 300;
  	text-shadow: none;

  	&-success {
  		background-color: @green;
  	}

  	&-important {
  		background-color: @red;
  	}

  	&-info {
  		background-color: @purple;
  	}

  	&-inverse {
  		background-color: @black;
  	}
  }

  .badge {

  	.border-radius(0);
  	font-weight: 300;
  	text-shadow: none;

  	&-success {
  		background-color: @green;
  	}

  	&-important {
  		background-color: @red;
  	}

  	&-info {
  		background-color: @purple;
  	}

  	&-inverse {
  		background-color: @black;
  	}
  }

  // MISC
  // -----------------------------------------------------

  .hero-unit {
  	border: none;
  	.border-radius(0);
  	.box-shadow(none);
  }

  .well {
  	border: none;
  	.border-radius(0);
  	.box-shadow(none);
  }

  [class^="icon-"], [class*=" icon-"] {
  	margin: 0 2px;
  	vertical-align: -2px;
  }

  a.thumbnail {
  	background-color: @grayLight;

  	&:hover {
  		background-color: @gray;
  		border-color: transparent;
  	}
  }

  .progress {
  	height: 6px;
  	.border-radius(0);
  	.box-shadow(none);
  	background-color: @grayLighter;
  	background-image: none;

  	.bar {
  		background-color: @blue;
  		background-image: none;
  	}

  	&-info {
  		background-color: @purple;
  	}

  	&-success {
  		background-color: @green;
  	}

  	&-warning {
  		background-color: @orange;
  	}

  	&-danger {
  		background-color: @red;
  	}
  }

  .modal {
  	.border-radius(0);

  	&-header {
  		border-bottom: none;
  	}

  	&-footer {
  		border-top: none;
  		background-color: transparent;
  	}
  }

  .popover {
  	.border-radius(0);
  	color: @white;

  	&-title {
  		border-bottom: none;
  		color: @white;
  	}

  }

  // MEDIA QUERIES
  // -----------------------------------------------------  
]
  end
  route "resources :#{controller_name}"
  route "root to: '#{controller_name}#index'"
  remove_file 'public/index.html'
end

# Step 8: Server start.sh
create_file "start.sh" do
  "RACK_ENV=none RAILS_ENV=development unicorn -c config/unicorn.rb"
end

# Final Step: Start and open
run 'sh start.sh'