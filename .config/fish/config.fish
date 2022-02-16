if status is-interactive
    # Commands to run in interactive sessions can go here
    source ("/usr/local/bin/starship" init fish --print-full-init | psub)
    #status is-login; and pyenv init --path | source
    pyenv init - | source
end



