import sys, time, threading
import curses

class Trainer:
    def __init__(self, alphabet):
        self.alphabet = alphabet
        self.start = None

def replace_line(stdscr, i, s):
    y, x = stdscr.getyx()
    stdscr.move(i,0)
    stdscr.clrtoeol()
    stdscr.addstr(s)
    stdscr.move(y, x)

def timer(stdscr, trainer):
    while trainer.start != None:
        y, x = stdscr.getyx()
        replace_line(stdscr, 0, '{:.4f}'.format(time.time() - trainer.start))
        stdscr.refresh()
        time.sleep(0.0001)

def train(stdscr, trainer):
    loop = True
    while loop:
        stdscr.clear()
        stdscr.addstr(0, 0, '{:.4f}'.format(0))
        stdscr.addstr(1, 0, f'enter the following, or press enter to quit')
        stdscr.addstr(2, 0, trainer.alphabet)
        stdscr.move(3,0)
        stdscr.refresh()

        c = '.'
        full = ''
        c_times = []
        while True:
            c = stdscr.getch()
            if c == ord('\n'):
                break

            if ord('A') <= c <= ord('z') or chr(c) in trainer.alphabet :
                ch = chr(c).lower()
                c_times.append(time.time())
                full = full + ch
                if len(full) - 1 < len(trainer.alphabet) and trainer.alphabet[len(full) - 1] == ch:
                    stdscr.addstr(3, len(full) - 1, f'{ch}', curses.color_pair(2))
                else:
                    stdscr.addstr(3, len(full) - 1, f'{ch}', curses.color_pair(1))
                if full == trainer.alphabet:
                    break
                if len(full) == 1:
                    trainer.start = time.time()
                    threading.Thread(target=timer, args = (stdscr, trainer)).start()
            elif c == curses.KEY_BACKSPACE:
                # backspace
                if len(full) >= 1:
                    full = full[:-1]
                    c_times = c_times[:-1]
                    stdscr.delch(3, len(full))
                    if len(full) == 0:
                        trainer.start = None
                        replace_line(stdscr, 0, '{:.4f}'.format(0))
            if trainer.start == None:
                stdscr.refresh()
            else:
                stdscr.noutrefresh()
        
        if not trainer.start:
            break

        elapsed = c_times[-1] - trainer.start
        trainer.start = None
        stdscr.clear()
        stdscr.addstr(0, 0, 'RESULTS')
        stdscr.addstr(1, 0, '{:.4f}'.format(elapsed), curses.A_STANDOUT)

        pad = curses.newpad(len(trainer.alphabet), 40)
        scrollok = False
        if full == trainer.alphabet:
            scrollok = True
            pad.scrollok(True)
            stdscr.addstr(3, 0, 'your time for each character was:\n')
            for i in range(len(trainer.alphabet)):
                elapsed = float(0 if i == 0 else c_times[i] - c_times[i - 1])
                pad.addstr(f'{trainer.alphabet[i]}: {elapsed:.4}')
                if i < len(trainer.alphabet) - 1:
                    pad.addstr('\n')
        else:
            stdscr.addstr(3, 0, 'you did not complete the characters\n')
            pad.addstr(f'{trainer.alphabet}\n')
            pad.addstr('')
            for i in range(len(full)):
                if i < len(trainer.alphabet) and trainer.alphabet[i] == full[i]:
                    stdscr.addstr(full[i], curses.color_pair(2))
                else:
                    stdscr.addstr(full[i], curses.color_pair(1))

        pad_height = min(stdscr.getmaxyx()[0] - 5, len(trainer.alphabet))
        pad_y = 0
        stdscr.addstr(pad_height + 4, 0, 'press enter or q to quit or any other key to try again')
        stdscr.refresh()
        while True:
            pad.refresh(pad_y, 0, 4, 0, pad_height, 40)
            c = stdscr.getch()
            ch = chr(c)
            if c == curses.KEY_UP and scrollok:
                pad_y = max(0, pad_y - 1)
            if c == curses.KEY_DOWN and scrollok:
                pad_y = min(len(trainer.alphabet) - pad_height + 3, pad_y + 1)
            if ch == '\n':
                break
            if ch.lower() == 'q':
                loop = False
                break
    
def train_alphabet(stdscr):
    trainer = Trainer('abcdefghijklmnopqrstuvwxyz')
    train(stdscr, trainer)

def train_custom(stdscr):
    stdscr.clear()
    stdscr.addstr('enter custom characters: ')
    stdscr.refresh()

    curses.echo()
    y, x = stdscr.getyx()
    custom = stdscr.getstr().decode(encoding="utf-8")
    curses.noecho()
    if custom:
        trainer = Trainer(custom)
        train(stdscr, trainer)

def run():
    stdscr = curses.initscr()
    curses.start_color()
    curses.init_pair(1, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.noecho()
    curses.cbreak()
    stdscr.keypad(True)
    menu_options = {
        'train': lambda : train_alphabet(stdscr),
        'custom': lambda : train_custom(stdscr),
        'quit': sys.exit
    }
    menu_aliases = {m[0]: menu_options[m] for m in menu_options.keys()}
    print(menu_aliases)

    while True:
        stdscr.clear()
        stdscr.addstr('choose option:\n')
        for m in menu_options.keys():
            stdscr.addstr(f'\n{m}')
        stdscr.addstr('\n')
        
        stdscr.refresh()
        c = stdscr.getkey()
        if c == 'q':
            break
        if c in menu_aliases.keys():
            menu_aliases[c]()
    curses.echo()
    curses.nocbreak()
    curses.endwin()

if __name__ == '__main__':
    run()
