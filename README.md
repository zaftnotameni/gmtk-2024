![](game/assets/logos/gmtk2024-logo.png)

Links:

- Repository: [https://github.com/zaftnotameni/gmtk-2024](https://github.com/zaftnotameni/gmtk-2024)
- Our Game on Itch: [https://hotnoggin.itch.io/gmtk-2024](https://hotnoggin.itch.io/gmtk-2024)
- Jam: [https://itch.io/jam/gmtk-2024](https://itch.io/jam/gmtk-2024)
- Theme: [https://www.youtube.com/watch?v=iIbTPpfvZBQ](https://www.youtube.com/watch?v=iIbTPpfvZBQ)

Categories:

- ⭐⭐⭐⭐⭐ **Enjoyment**
- ⭐⭐⭐⭐⭐ **Creativity**
- ⭐⭐⭐⭐⭐ **Presentation**

Team:

- [HotNoggin](https://github.com/HotNoggin)
- [TheNetherPug](https://github.com/TheNetherPug)
- [ZAFT](https://github.com/zaftnotameni)

## Running the Project

If you are on windows and have the correct Godot version with the default name in a folder on your path, you can just run:

```ps
bat\editor-rc.bat
```

That line will automatically start Godot 4.3-rc3 in verbose mode, skipping the project selection screen.

## Deploying the project

The project should be exported to (those folders already have a `.gdignore` so the editor won't load them):

- `res://exports/web`: web version
- `res://exports/win`: windows version
- `res://exports/lin`: linux version

After exporting, the following commands (assuming you have butler setup) will deploy each version:

- `bat\itch-web.bat`: web version
- `bat\itch-win.bat`: windows version
- `bat\itch-lin.bat`: linux version

## Automatic builds on Github

Pushing a tag in the format `v0.0.1` (the `v` is important) triggers an automatic build on github for all platforms.

This might not be fully functional though because it can be missing secrets (like leaderboard api keys).

