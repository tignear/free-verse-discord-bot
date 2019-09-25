# frozen_string_literal: true

# NOTE: "Ikku::Reviewer" is so long and "reviewr" is so ambiguous
# that we call it "basho", named after "Matsuo Basho".

class FreeVerseBot
  def initialize(args)
    @bot = args[:discordrb_bot]
    @get_rule = args[:get_rule]
    @get_basho = args[:get_ikku_reviewer]
    @mecab = args[:mecab]
    @debug_mode = args[:debug_mode]
  end

  def handle_message_event(event)
    author_name = event.author.username
    rule = @get_rule.call
    basho = @get_basho.call(rule: rule)
    songs = basho.search(event.content)
    songs.each do |song|
      verses = song.phrases.map do |phrase|
        phrase.map(&:to_s).join
      end
      event.respond <<~EOD
        ┏━━━━━━━━━━━　**本日の一句**　━━━━━━━━━━━
        ┃
        ┃　　#{verses[0]}
        ┃
        ┃　　　　#{verses[1]}
        ┃
        ┃　　　　　　#{verses[2]}
        ┃
        ┃　　　　　　　　　　　　　　　　　　詠み手：#{author_name}
        ┃
        ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      EOD
    end
  end

  def handle_mention_event(event)
    command_format = "<@#{@bot.profile.id}> %s"
    mecab_format = format(command_format, 'mecab')
    info_format = format(command_format, 'info')

    if event.content.start_with? mecab_format
      message = event.content.delete_prefix(mecab_format).lstrip
      mecab_command(message, event)
    elsif @debug_mode and event.content.start_with? info_format
      info_command(event)
    end
  end

  private

  def mecab_command(message, event)
    event.respond "```\n#{@mecab.parse(message)}\n```"
  end

  def info_command(event)
    server_names = @bot.servers.map do |id, server|
      "<#{id}> #{server.name}"
    end.join("\n")
    event.respond "I'm in these servers:\n#{server_names}"
  end
end