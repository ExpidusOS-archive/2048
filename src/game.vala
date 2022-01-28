namespace Expidus2048 {
  public enum Direction {
    LEFT, RIGHT, UP, DOWN
  }
  
  public enum GameState {
    PAUSED,
    PLAYING,
    LOST,
    WIN
  }

  public class Game : GLib.Object {
    public uint64[] board;
    public int32 board_width { get; construct; }
    public int32 board_height { get; construct; }
    public uint64 score { get; }
    public GameState state { get; }
    
    private uint64*[] _fspace;
    private uint64[] _breg;
    private uint64[] _freg;
    
    public Game(int32 board_width, int32 board_height) {
      Object(board_width: board_width, board_height: board_height);
    }
    
    construct { 
      this.board = new uint64[this.board_width * this.board_height];
      this._fspace = new uint64*[this.board_width * this.board_height];
      this.reset_regs();
      this.rand_piece();
      this._state = GameState.PLAYING;
    }

    private void reset_regs() { 
      this._breg = new uint64[this.board_width];
      this._freg = new uint64[this.board_width];
    }
    
    private void set_line(int idx, uint64[] line) {
      for (var i = 0; i < this.board_width; i++) this.board[idx * this.board_width + i] = line[i];
    }
    
    private bool compare_line(uint64[] a, uint64[] b) {
      for (var i = 0; i < this.board_width; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
    
    private uint64[] get_line(int idx, out uint64[] reg) {
      reg = new uint64[this.board_width];
      for (var i = 0; i < this.board_width; i++) reg[i] = this.board[idx * this.board_width + i];
      return reg;
    }

    private uint64[] move_line(uint64[] line) {
      var size = 0; 
      for (var i = 0; i < this.board_width; i++) {
        if (line[i] > 0) this._freg[size++] = line[i];
      }

      if (size == 0) GLib.Memory.copy(this._freg, line, this.board_width * sizeof (uint64));
      return this._freg;
    }
    
    private uint64[] merge_line(uint64[] line) {
      this._breg = new uint64[this.board_width];
      var size = 0;
      for (var i = 0; i < this.board_width; i++) {
        var val = line[i];
        if (i < (this.board_width - 1) && line[i] == line[i + 1]) {
          val *= 2;
          
          this._score += val;
          this.notify_property("score");
          
          if (val == 2048) {
            this._state = GameState.WIN;
            this.notify_property("state");
          }
          
          i++;
        }

        this._breg[size++] = val;
      }

      if (size == 0) GLib.Memory.copy(this._breg, line, this.board_width * sizeof (uint64));
      return this._breg;
    }
    
    private void left() { 
      bool need_add_tile = false;
      for (var i = 0; i < this.board_height; i++) {
        this.reset_regs();
        var line = this.get_line(i, out this._breg);
        var merged = this.merge_line(this.move_line(line));
        line = this.get_line(i, out this._freg);
        var res = this.compare_line(line, merged);
        this.set_line(i, merged);
        if (!need_add_tile && !res) need_add_tile = true;
      }

      if (need_add_tile) this.rand_piece();
    }
    
    private void reset_space() {
      for (var i = 0; i < this.board_width * this.board_height; i++) {
        this._fspace[i] = null;
      }
    }
    
    public void set_piece(int32 x, int32 y, uint64 numb) {
      this.board[x * this.board_width + y] = numb;
      this.draw();
    }
    
    public uint64 get_piece(int32 x, int32 y) {
      return this.board[x * this.board_width + y];
    }
    
    public void rand_piece() {
      while (true) {
        var x = GLib.Random.int_range(0, this.board_width);
        var y = GLib.Random.int_range(0, this.board_height);

        var n = this.get_piece(x, y);
        if (n != 0) continue;

        this.set_piece(x, y, 2);
        break;
      }
    }
    
    public bool can_move() {
      for (var x = 0; x < this.board_width; x++) {
        for (var y = 0; y < this.board_height; y++) {
          if ((x < this.board_width - 1) && this.get_piece(x, y) == this.get_piece(x + 1, y)
            || (y < (this.board_height - 1) && this.get_piece(x, y) == this.get_piece(x, y + 1))) return true;
        }
      }
      return false;
    }
    
    public void rotate(int amount) {
      for (; amount >= 90; amount -= 90) {
        var rot = new uint64[this.board_width * this.board_height];
        for (var x = 0; x < this.board_width; x++) {
          for (var y = 0; y < this.board_height; y++) {
            rot[x * this.board_width + y] = this.board[(this.board_height - y - 1) * this.board_width + x];
          }
        }
        GLib.Memory.copy(this.board, rot, sizeof (uint64) * (this.board_width * this.board_height));
      }
    }
    
    public void move(Direction dir) {
      if (!this.can_move()) {
        this._state = GameState.LOST;
        this.notify_property("state");
        return;
      }

      switch (dir) {
        case Direction.LEFT:
          this.left();
          break;
        case Direction.RIGHT:
          this.rotate(180);
          this.left();
          this.rotate(180);
          break;
        case Direction.UP:
          this.rotate(270);
          this.left();
          this.rotate(90);
          break;
        case Direction.DOWN:
          this.rotate(90);
          this.left();
          this.rotate(270);
          break;
      }
      this.draw();
    }
    
    public signal void draw();
  }
}