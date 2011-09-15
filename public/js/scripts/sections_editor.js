$(document).ready(function(){
  
  // find a way to get around this global variable thing.
  sections_list = { build: $.noop() };
  
  var powers_of_two = { 0:1, 1:2, 2:4, 3:8, 4:16, 5:32, 6:64 };
  
  // segment class
  // find some way to make it an instrumental
  var new_segment = function(line,position,chord,lyrics) {
    var segment = {
      line: line,
      position: position,
      chord: chord ? chord : "",
      lyrics: lyrics ? lyrics : [""],
      pickup: (position == 'p') ? true : false,
      clear_lyrics: function() {
        this.lyrics = $.map(this.lyrics, function(lyrics,i) { return ""; } );
      },
      add_variation: function() {
        this.lyrics.push("");
      },
      delete_variation: function(variation) {
        this.lyrics.splice(variation-1,1);
      },
      clone: function() {
        return new_segment(this.line,this.position,this.chord,this.lyrics.slice(0));
      },
      merge_lyrics: function(other) {
        var merged_lyrics = [];
        var variation_count = lyrics.length;
        for(var i=0; i<variation_count; i++) {
          var lyric_1 = this.lyrics[i];
          var lyric_2 = other.lyrics[i];
          
          var merged_lyric = lyric_1;
          
          // fix some edge cases like double spaces. idk.
          
          if (merged_lyric.slice(-1) == '-') {
            merged_lyric = merged_lyric.slice(0,-1);
          }
          
          if (lyric_2 == '' || lyric_2 == ' ' || $.trim(lyric_2) == '') {
            merged_lyrics.push(merged_lyric);
          } else {
            merged_lyrics.push(merged_lyric + lyric_2);
          }
          
          
        }
        return merged_lyrics;
      },
      build: function(variation,instrumental) {
        
        var segment_div = $('<div/>').attr('class','es-segment');
        
        var chord_div = $('<div/>').attr('class','es-chord');
        var lyrics_div = $('<div/>').attr('class','es-lyrics');
        var options_div = $('<div/>').attr('class','es-segment_opts');
        
        var lyrics_inp = $('<input/>').attr('class','es-lyrics_inp').val(this.lyrics[variation-1]);
        
        segment_div.append(chord_div,lyrics_div,options_div);
        lyrics_div.append(lyrics_inp);
        
        if (this.pickup) {
          var pickup_text = $('<span/>').attr('class','es-pickup_indicator').html("(pickup)");
          chord_div.append(pickup_text);
        } else {
          var chord_inp = $('<input/>').attr('class','es-chord_inp').val(this.chord);
          chord_div.append(chord_inp);
          
          if (variation > 1) {
            chord_inp.attr('disabled','disabled');
          } else {
            chord_inp.change(function() { segment.change_chord(chord_inp.val(),chord_inp); });
            
            var split_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'es-split_segment_link' }).html('Split').click(function() {
              segment.line.split_segment(segment);
              sections_list.build();
            });
            options_div.append(split_link);
          }
        }
        
        lyrics_inp.change(function() { segment.change_lyrics(variation-1,lyrics_inp.val()); });
        
        if (instrumental) {
          lyrics_div.css('display','none');
        }
        
        return segment_div;
      },
      update: function() {
        
      },
      change_chord: function(new_chord,textbox) {       //textbox will be null if not called from textbox
        if (false) {
          alert('Invalid chord.');
          textbox.focus();
          textbox.select();
        } else {
          this.chord = new_chord;
          // sections_list.build();
        }
      },
      change_lyrics: function(variation,new_lyrics) {
        this.lyrics[variation] = new_lyrics;
        // sections_list.build();
      }
    };
    return segment;
  };
  
  // line class
  var new_line = function(section,starting_segments) {
    var line = {
      section: section,
      segments: [],
      add_segment: function(pos) {
        var added_segment = new_segment(this,pos);
        this.segments.push(added_segment);
        return added_segment;
      },
      split_segment: function(segment) {
        var segment_index = this.segments.indexOf(segment);
        var new_segment_1 = segment.clone();
        var new_segment_2 = segment.clone();
        
        new_segment_1.position += "0";
        new_segment_2.position += "1";
        
        new_segment_2.clear_lyrics();
        
        this.segments.splice(segment_index,1,new_segment_1,new_segment_2);
        
        return [new_segment_1,new_segment_2];
      },
      merge_segments: function(position) {
        
        // alert(position);
        // alert(JSON.stringify($.map(this.segments.slice(1),function (segment) { return (segment ? segment.position : "") ;  })));
        
        var to_merge = this.segments.filter( function (segment) {
          return (segment.position.indexOf(position) == 0);
        });
        
        // alert(JSON.stringify($.map(to_merge,function (segment) { return (segment ? segment.position : "") ;  })));
        
        if (to_merge.length != 2) {
          alert('Bad position: ' + to_merge.length + ' sections have position "' + position + '".');
          return null;
        } else {
          // consider not making a new segment but simply changing the to_merge[0] ?
          var merged_segment = to_merge[0].clone();
          var merged_lyrics = to_merge[0].merge_lyrics(to_merge[1]);
          
          merged_segment.lyrics = merged_lyrics;
          merged_segment.position = position;
          var segment_index = this.segments.indexOf(to_merge[0]);
          this.segments.splice(segment_index,2,merged_segment);
          return merged_segment;
        }
      },
      add_pickup: function() {
        var pickup = new_segment(this,'p');
        if (this.segments.length == 0) {
          this.segments.push(pickup);
        } else {
          this.segments.splice(0,0,pickup);
        }
        return pickup;
      },
      // delete_pickup: function() {
        // var pickup = this.segments[0];
        // if (pickup.position == 'p') {
          // this.segments.splice(0,1);
        // }
      // },
      add_variation: function() {
        this.segments.forEach(function(segment) {
          segment.add_variation();
        });
      },
      delete_variation: function(variation) {
        this.segments.forEach(function(segment) {
          segment.delete_variation(variation);
        });
      },
      build: function(variation,instrumental) {
        var line_div = $('<div/>').attr('class','es-line');
        var segments_list = $('<ul/>').attr( {'class': 'es-segments_ul'} );
        
        this.segments.forEach(function(segment) {
          var list_item = $('<li/>').attr({ 'class':'es-segment_li' });
          var segment_div = segment.build(variation,instrumental);
          
          if (segment.position != 'p') {
            if (instrumental) {
              list_item.css('width',100 / powers_of_two[segment.position.length - 1] + '%');
            } else {
              list_item.css('width',85 / powers_of_two[segment.position.length - 1] + '%');
            }
          } else {
            list_item.addClass('es-pickup_li');
            list_item.css('width','15%');
          }
          
          list_item.append(segment_div);
          segments_list.append(list_item);
          
          if (instrumental && segment.position == 'p') {
            list_item.css('display','none');
          }
          
        });
        
        line_div.append(segments_list);
        
        var options_div = $('<div/>').attr('class','es-line_opts');
        var this_line = this;
        
        
        if (this.section.lines.length > 1) {
          if (variation == 1)
          {
            var delete_line_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'es-delete_line_link' }).html('Delete Line').click(function() {
              this_line.section.delete_line(line);
              sections_list.build();
            });
            options_div.append(delete_line_link);
          }
        }
        
        line_div.append(options_div);
        
        return line_div;
      },
      update: function() {
        this.segments.forEach( function(segment) {
          segment.update();
        });
      }
    };
    
    line.add_pickup();
    
    // alert(JSON.stringify($.map(this.segments,function (segment) { return (segment ? segment.position : "") ;  })));
    
    var sg = starting_segments ? starting_segments : 4;
    
    // make this work for other time signatures or something.  hm.
    if (sg > 0) {
      var segment_0 = line.add_segment('0');
      var all_segments = [segment_0];
      
      while (all_segments.length < sg) {
        
        var segment_pool = [];
        all_segments.forEach( function(segment) {
          var children = line.split_segment(segment);
          segment_pool.push(children[0]);
          segment_pool.push(children[1]);
        });
        
        all_segments = segment_pool;
        
      }
    }
    
    return line;
  };
  
  // section class
  // find some way to make it an instrumental
  var new_section = function(title,instrumental,no_line) {
    var section = {
      title: title ? title : "",
      variations_count: 1,
      lines: [],
      instrumental: instrumental ? true : false,
      add_line: function(starting_segments) {
        var added_line = new_line(this,starting_segments);
        this.lines.push(added_line);
        return added_line;
      },
      delete_line: function(line) {
        var line_num = this.lines.indexOf(line);
        this.lines.splice(line_num,1);
      },
      add_variation: function() {
        if (this.instrumental) {
          alert('what the heck are you doing, adding a variation to an instrumental?');
        } else {
          this.lines.forEach(function(line) {
            line.add_variation();
          });
          this.variations_count += 1;
        }
      },
      delete_variation: function(variation) {
        if (variation <= this.variations_count) {
          this.lines.forEach(function(line) {
            line.delete_variation(variation);
          });
          this.variations_count -= 1;
        }
      },
      make_instrumental: function(variation) {
        // maybe add confirmation?
        if (!this.instrumental) {
          // while (this.variations_count > 1) {
            // this.delete_variation(this.variations_count);
          // }
          // lines.forEach(function(line) {
            // line.add_pickup();
          // })
          this.instrumental = true;
        }
      },
      unmake_instrumental: function(variation) {
        if (this.instrumental) {
          // lines.forEach(function(line) {
              // line.delete_pickup();
            // })
          this.instrumental = false;
        }
      },
      // variations start from 1, here
      build_variation: function(variation) {
        var variation_div = $('<div/>').attr('class','es-variation');
        
        var title_div = $('<div/>').attr('class','es-variation_title');
        var title_span = $('<span/>').attr('class','es-variation_title_span').html(this.title + " " + (variation));
        
        title_div.append(title_span);
        variation_div.append(title_div);
        
        var lines_list = $('<ul/>').attr('class', 'es-lines_ul');
        
        var instrumental = this.instrumental;
        
        this.lines.forEach(function(line) {
          var list_item = $('<li/>').attr('class','es-line_li');
          var line_div = line.build(variation,instrumental);
          
          list_item.append(line_div);
          lines_list.append(list_item);
        });
        
        variation_div.append(lines_list);
        
        var options_div = $('<div/>').attr('class','es-variation_opts');
        
        if (variation==1) {
          
          var add_line_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'es-add_line_link' }).html('Add Line').click(function() {
            section.add_line();
            sections_list.build();
          });
          options_div.append(add_line_link);
          
        }
        if (this.variations_count == 1) {
          title_span.css('display','none');
        } else {
          
          var delete_variation_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'es-delete_variation_link' }).html('Delete Variation').click(function() {
            section.delete_variation(variation);
            sections_list.build();
          });
          options_div.append(add_line_link);
          
        }
        
        variation_div.append(options_div);
        
        
        return variation_div;
      },
      build: function() {
        var section_div = $('<div/>').attr('class','es-section');
        if (this.instrumental) {
          section_div.addClass('es-instrumental-section');
        }
        
        var title_div = $('<div/>').attr('class','es-section_title');
        // var title_span = $('<span/>').attr('class','es-section_title_span').html(this.title);
        
        var title_inp = $('<input/>').attr({'class':'es-section_title_inp', 'placeholder':'New Title'});
        title_inp.defaultValue();
        
        title_inp.val(this.title);
        
        var instrumental_indicator = $('<span/>').attr('class','es-instrumental_indicator');
        
        title_div.append(title_inp);
        title_div.append(instrumental_indicator);
        section_div.append(title_div);
        
        title_inp.change(function() { section.change_title(title_inp.val(),title_inp); });
        if (this.instrumental) {
          instrumental_indicator.html('(Instrumental)');
        }
        
        var variations_list = $('<ul/>').attr('class', 'es-variations_ul');
        
        var iter_count = 1;
        if (!this.instrumental) {
          iter_count = this.variations_count;
        }
        
        var i;
        for (i=0;i<iter_count;i++) {
          var list_item = $('<li/>').attr('class','es-variation_li' );
          var variation_div = this.build_variation(i+1);
          
          list_item.append(variation_div);
          variations_list.append(list_item);
        }
        
        section_div.append(variations_list);
        
        var options_div = $('<div/>').attr('class','es-section_opts');
        
        if (!this.instrumental) {
        
          var add_var_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'es-add_variation_link' }).html('Add Variation').click(function() {
            section.add_variation();
            sections_list.build();
          });
          var make_instrumental_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'es-make_instrumental_link' }).html('Make Instrumental').click(function() {
            section.make_instrumental();
            sections_list.build();
          });
          options_div.append(add_var_link);
          options_div.append(make_instrumental_link);
        } else {
          var unmake_instrumental_link = $('<a/>').attr({ 'href':'javascript:;', 'class':'es-unmake_instrumental_link' }).html('Make Not Instrumental').click(function() {
            section.unmake_instrumental();
            sections_list.build();
          });
          options_div.append(unmake_instrumental_link);
        }
        
        section_div.append(options_div);
        
        return section_div;
      },
      update: function() {
        this.lines.forEach( function(line) {
          line.update();
        });
      },
      change_title: function(new_title,textbox) {
        if (false) {
          alert('Invalid Title');
          textbox.focus();
          textbox.select();
        } else {
          this.title = new_title;
        }
      }
    };
    
    
    if (!no_line) {
      section.add_line();
    }
    
    return section;
    
  };
  
  
  // list of sections -- singleton
  sections_list = {
    sections: [],
    add_section: function(title,instrumental,no_build,no_focus,no_line) {
      var added = new_section(title,instrumental,no_line);
      this.sections.push(added);
      
      if (!no_build) {
        this.build();
        
        var new_section_title = $('.es-section_title_inp').last();
        
        if (!no_focus) {
          new_section_title.focus();
          new_section_title.select();
        }
      }
      
      return added;
    },
    build: function() {
      var sections_ul = $(".es-sections_ul");
      sections_ul.empty();
      
      this.sections.forEach(function(section) {
        var list_item = $('<li/>').attr('class','es-section_li');
        var section_div = section.build();
        
        list_item.append(section_div);
        sections_ul.append(list_item);
        
      });
    },
    update: function() {
      this.sections.forEach(function(section) {
        section.update();
      });
    }
  };
  
});