Сведи проектные аргументы NixOS-модулей и пакетов к одному `extensions` в отдельном изменении SpecD.

После разделения функциональных `modules` и `configs` контекст содержит `extensions.modules`, `extensions.configs`, `extensions.flake-inputs` и `extensions.pkgsUnstable`. Он передаётся через `specialArgs` и публикуется в `pkgs`. Пока сохранены отдельные `flake-inputs`, `pkgsUnstable` и служебный `projectTestConfig` ради совместимости.

Найди потребителей проектных аргументов, переведи их на `extensions` и удали лишние дубли в `specialArgs`, `_module.args` и пакетном overlay. Проектный `lib` заменяет стандартный и остаётся обычным аргументом `lib`; в `extensions` его переносить не нужно. Сохрани стандартные аргументы NixOS (`config`, `options`, `pkgs`). Не добавляй универсальные прокси, новые scope или обёртки над `callPackage`.

Сохрани добавление `modules`/`configs` через `.extend`, выбор платформы пакетов и работу существующих `runNixOSTest`/`extendNixOS`. Тесты должны получать функциональные модули, без конфигурации хостов и validation stubs. Если для этого требуется усложнение, обсуди его с владельцем.

Сначала покажи код. Проверки начинай с небольших eval; VM запускай по одной, сборки — `--max-jobs 1 --cores 2`. Для тяжёлого eval используй systemd scope (`MemoryHigh=4G`, `MemoryMax=4608M`, `MemorySwapMax=16G`) и следи за всем деревом Nix/daemon/VM, останавливаясь при приближении RAM к 5 ГБ. Не запускай `allTests` первым.
