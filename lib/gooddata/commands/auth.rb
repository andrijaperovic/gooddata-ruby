module GoodData::Command
  class Auth < Base
    def connect
      unless defined? @connected
        GoodData.connect user, password, url
        @connected = true
      end
      @connected
    end

    def user
      ensure_credentials
      @credentials[:username]
    end

    def password
      ensure_credentials
      @credentials[:password]
    end

    def url
      ensure_credentials
      @credentials[:url]
    end

    def credentials_file
      "#{home_directory}/.gooddata"
    end

    def ensure_credentials
      return if defined? @credentials
      unless @credentials = read_credentials
        @credentials = ask_for_credentials
      end
      @credentials
    end

    def read_credentials
      if File.exists?(credentials_file) then
        config = File.read(credentials_file)
        JSON.parser.new(config, :symbolize_names => true).parse
      end
    end

    def ask_for_credentials
      puts "Enter your GoodData credentials."
      user = ask("Email")
      password = ask("Password", :secret => true)
      { :username => user, :password => password }
    end

    def store
      credentials = ask_for_credentials

      ovewrite = if File.exist?(credentials_file)
        ask "Overwrite existing stored credentials", :answers => %w(y n)
      else
        'y'
      end

      if ovewrite == 'y'
        File.open(credentials_file, 'w', 0600) do |f|
          f.puts JSON.pretty_generate(credentials)
        end
      else
        puts 'Aborting...'
      end
    end

    def unstore
      FileUtils.rm_f(credentials_file)
    end
  end
end