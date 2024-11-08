{ pkgs, ... }:
let
  notify_timeout = 10;
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [desktop-notifier]);
  watcher = pkgs.writers.writePython3 "kitty-watcher" { } ''
    import sys
    import asyncio
    from typing import Any, List, Dict, Coroutine
    from threading import Lock

    from kitty.boss import Boss
    from kitty.window import Window

    sys.path.append('${pythonEnv}/lib/python3.11/site-packages/')  # noqa: E501

    from desktop_notifier import DesktopNotifier, Notification  # noqa: E402


    class Windows:
        mutex = Lock()
        windows: Dict[int, Dict[int, Notification | None]] = {}
        notifier = DesktopNotifier(app_name="Terminal")
        _loop = asyncio.DefaultEventLoopPolicy().new_event_loop()

        def set_start_time(self, id: int, start: float) -> None:
            with self.mutex:
                self._check_id(id)
                self.windows[id][0] = start

        def get_running_time(self, id: int, cur: float) -> float:
            with self.mutex:
                self._check_id(id)
                if self.windows[id][0] is None:
                    return cur
                else:
                    return cur - self.windows[id][0]

        def notify_end(self,
                       id: int,
                       cmd: List[str] | None,
                       time: int,
                       boss: Boss,
                       window: Window) -> None:
            with self.mutex:
                self._clear_notiffication(id)
                message = f"'{cmd[0]}'" if cmd else "Command"
                n = self.notifier.send(
                    title="Terminal",
                    message=f"{message} finished in {int(time)}s",
                    icon="utilities-terminal",
                    # TODO(Shvedov): This does not work. Prepare script which
                    # will interact with hdrop and kitten
                    on_clicked=lambda: boss.remote_control(
                        'focus-window',
                        f'--match=id:{window.id}')
                )
                self.windows[id][1] = self._run_coro_sync(n)

        def clear_notiffication(self, id: int) -> None:
            with self.mutex:
                self._clear_notiffication(id)

        def _clear_notiffication(self, id: int) -> None:
            self._check_id(id)
            n = self.windows[id][1]
            if n is not None:
                c = self.notifier.clear(n)
                c = self._run_coro_sync(c)
            self.windows[id][1] = None

        def _check_id(self, id: int):
            if id not in self.windows:
                self.windows[id] = {0: None, 1: None}

        def _run_coro_sync(self, coro: Coroutine[None, None, Any]) -> Any:
            if self._loop.is_running():
                future = asyncio.run_coroutine_threadsafe(coro, self._loop)
                res = future.result()
            else:
                res = self._loop.run_until_complete(coro)

            return res


    windows = Windows()


    def on_focus_change(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
        if data["focused"]:
            windows.clear_notiffication(window.id)


    def on_cmd_startstop(boss: Boss, window: Window, data: Dict[str, Any]) -> None:
        time = data["time"]
        if data["is_start"]:
            cmd = data.get('cmdline', window.child.cmdline)
            windows.set_start_time(window.id, time)
        else:
            time = windows.get_running_time(window.id, time)
            if time > ${builtins.toString notify_timeout} and not window.is_focused:
                cmd = data.get('cmdline', None)
                windows.notify_end(window.id, cmd, time, boss, window)
  '';
in
{
  programs.hyprland.hyprconfig = {
    "kitty/kitty.conf" = {
      hypr = false;
      text = ''
        background_opacity            0.7

        scrollback_lines              200000
        scrollback_pager_history_size 1024

        tab_bar_min_tabs              1
        tab_bar_style                 powerline

        enabled_layouts               horizontal

        allow_remote_control          yes

        watcher                       ${watcher}
      '';
    };
  };
}

