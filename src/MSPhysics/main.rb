require 'MSPhysics.rb'

msg = 'You cannot load MSPhysics extension until SketchUp meets all the plugin compatibility demands!'
raise(msg) unless defined?(MSPhysics::NAME)

require 'ams_Lib.rb'
AMS::Lib.require_all
AMS::Lib.require_library 'ams_ffi.rb'

dir = File.dirname(__FILE__)

require File.join(dir, 'group.rb')
require File.join(dir, 'geometry.rb')
require File.join(dir, 'conversion.rb')
require File.join(dir, 'utility.rb')
require File.join(dir, 'newton.rb')
require File.join(dir, 'collision.rb')
require File.join(dir, 'contact.rb')
require File.join(dir, 'hit.rb')
require File.join(dir, 'material.rb')
require File.join(dir, 'materials.rb')
require File.join(dir, 'context.rb')
require File.join(dir, 'body_observer.rb')
require File.join(dir, 'body.rb')
require File.join(dir, 'body_context.rb')
require File.join(dir, 'joint.rb')
require File.join(dir, 'animation.rb')
require File.join(dir, 'simulation.rb')
require File.join(dir, 'simulation_tool.rb')
require File.join(dir, 'joint_tool.rb')
require File.join(dir, 'joint_connection_tool.rb')
require File.join(dir, 'cloth.rb')
require File.join(dir, 'custom_cloth.rb')
require File.join(dir, 'particle_effects.rb')
require File.join(dir, 'dialog.rb')
require File.join(dir, 'settings.rb')

unless file_loaded?(__FILE__)

  # Add Some Materials.
  # Coefficients are defined from material to material contacts. Material to
  # another material coefficients are automatically calculated by averaging out
  # the coefficients of both.
  # [ name, density (kg/m^3), static friction, kinetic friction, elasticity, softness ]
  # Many coefficient values are estimated, averaged up, made up, and not accurate.
  mats = [
    ['Aluminum', 2700, 0.42, 0.34, 0.30, 0.01],
    ['Brass', 8730, 0.35, 0.24, 0.40, 0.01],
    ['Brick', 1920, 0.60, 0.55, 0.20, 0.01],
    ['Bronze', 8200, 0.36, 0.27, 0.60, 0.01],
    ['Cadnium', 8640, 0.79, 0.46, 0.60, 0.01],
    ['Cast Iron', 7300, 0.51, 0.40, 0.60, 0.01],
    ['Chromium', 7190, 0.46, 0.30, 0.60, 0.01],
    ['Cobalt', 8746, 0.56, 0.40, 0.60, 0.01],
    ['Concrete', 2400, 0.62, 0.56, 0.20, 0.01],
    ['Glass', 2800, 0.90, 0.72, 0.4, 0.01],
    ['Copper', 8940, 0.55, 0.40, 0.60, 0.01],
    ['Gold', 19320, 0.49, 0.39, 0.60, 0.01],
    ['Graphite', 2230, 0.18, 0.14, 0.10, 0.01],
    ['Ice', 916, 0.01, 0.01, 0.10, 0.01],
    ['Nickel', 8900, 0.53, 0.44, 0.60, 0.01],
    ['Plastic', 1000, 0.35, 0.30, 0.69, 0.01],
    ['Rubber', 1100, 1.16, 1.16, 0.90, 0.01],
    ['Silver', 10500, 0.50, 0.40, 0.60, 0.01],
    ['Steel', 8050, 0.31, 0.23, 0.60, 0.01],
    ['Teflon', 2170, 0.04, 0.03, 0.10, 0.01],
    ['Titanium', 4500, 0.36, 0.30, 0.40, 0.01],
    ['Tungsten Carbide', 19600, 0.22, 0.15, 0.40, 0.01],
    ['Wood', 700, 0.50, 0.25, 0.40, 0.01],
    ['Zinc', 7000, 0.60, 0.50, 0.60, 0.01]
  ]
  mats.each{ |args|
    mat = MSPhysics::Material.new(*args)
    MSPhysics::Materials.add(mat)
  }


  # Create tool bars and menus.

  sim_tool = MSPhysics::SimulationTool
  settings = MSPhysics::Settings
  plugin_menu = UI.menu('Plugins').add_submenu('MSPhysics')
  toolbar = UI::Toolbar.new 'MSPhysics Simulation'
  joints_toolbar = UI::Toolbar.new 'MSPhysics Joints'


  cmd = UI::Command.new('cmd'){
    MSPhysics::Dialog.visible = !MSPhysics::Dialog.visible?
  }
  cmd.menu_text = cmd.tooltip = 'UI'
  cmd.status_bar_text = 'Show/Hide MSPhysics UI.'
  cmd.set_validation_proc {
    MSPhysics::Dialog.visible? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/ui.png'
  cmd.large_icon = 'images/large/ui.png'
  toolbar.add_item(cmd)
  plugin_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    tool = MSPhysics::JointConnectionTool
    tool.active? ? tool.deactivate : tool.activate
  }
  cmd.menu_text = cmd.tooltip = 'Joint Connection Tool'
  cmd.status_bar_text = 'Activate/Deactivate joint connection tool.'
  cmd.set_validation_proc {
    MSPhysics::JointConnectionTool.active? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/joint connection tool.png'
  cmd.large_icon = 'images/large/joint connection tool.png'
  toolbar.add_item(cmd)
  plugin_menu.add_item(cmd)


  toolbar.add_separator
  sim_menu = plugin_menu.add_submenu('Simulation')


  cmd = UI::Command.new('cmd'){
    if sim_tool.active?
      sim_tool.instance.toggle_play
    else
      sim_tool.start
    end
  }
  cmd.menu_text = cmd.tooltip = 'Toggle Play'
  #~ cmd.status_bar_text = 'Play/Pause simulation. To simulate particular bodies, simply start simulation with the desired entities in selection.'
  cmd.status_bar_text = 'Play/Pause simulation.'
  cmd.set_validation_proc {
    next MF_UNCHECKED unless sim_tool.active?
    sim_tool.instance.playing? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/play.png'
  cmd.large_icon = 'images/large/play.png'
  toolbar.add_item(cmd)
  sim_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    sim_tool.reset
  }
  cmd.menu_text = cmd.tooltip = 'Reset'
  cmd.status_bar_text = 'Reset simulation.'
  cmd.set_validation_proc {
    MF_GRAYED unless sim_tool.active?
  }
  cmd.small_icon = 'images/small/reset.png'
  cmd.large_icon = 'images/large/reset.png'
  toolbar.add_item(cmd)
  sim_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    settings.record_animation_enabled = !settings.record_animation_enabled?
  }
  cmd.menu_text = cmd.tooltip = 'Record'
  cmd.status_bar_text = 'Toggle record simulation.'
  cmd.set_validation_proc {
    settings.record_animation_enabled? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/record.png'
  cmd.large_icon = 'images/large/record.png'
  toolbar.add_item(cmd)
  sim_menu.add_item(cmd)


  toolbar.add_separator
  sim_menu.add_separator


  cmd = UI::Command.new('cmd'){
    settings.continuous_collision_mode_enabled = !settings.continuous_collision_mode_enabled?
  }
  cmd.menu_text = cmd.tooltip = 'Continuous Collision Mode'
  cmd.status_bar_text = "Enable/Disable continuous collision check. This prevents bodies from passing each other at high speeds."
  cmd.set_validation_proc {
    settings.continuous_collision_mode_enabled? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/continuous collision.png'
  cmd.large_icon = 'images/large/continuous collision.png'
  toolbar.add_item(cmd)
  sim_menu.add_item(cmd)


  toolbar.add_separator
  sim_menu.add_separator


  solver_menu = sim_menu.add_submenu('Solver Model')
  solver_models = [
    ['Exact', 'Use exact solver model when precision is more important than performance.', 0],
    ['Ineractive 1 Pass', 'Use ineractive when performance is more important than precision.', 1],
    ['Ineractive 2 Passes', 'Use ineractive when performance is more important than precision.', 2],
    ['Ineractive 4 Passes', 'Use ineractive when performance is more important than precision.', 4],
    ['Ineractive 8 Passes', 'Use ineractive when performance is more important than precision.', 8],
    ['Ineractive 16 Passes', 'Use ineractive when performance is more important than precision.', 16]
  ]
  solver_models.each { |name, description, model|
    cmd = UI::Command.new('cmd'){
      settings.solver_model = model
    }
    cmd.menu_text = cmd.tooltip = name
    cmd.status_bar_text = description
    cmd.set_validation_proc {
      settings.solver_model == model ? MF_CHECKED : MF_UNCHECKED
    }
    solver_menu.add_item(cmd)
  }


  speed_menu = sim_menu.add_submenu('Speed')
  update_rates = [
      ['Double', 1/30.0],
      ['Normal', 1/60.0]
  ]
  for i in 1..10
    name = "x 1/#{i*2}"
    rate = 1.0/(60*i*2)
    update_rates << [name, rate]
  end
  update_rates.each { |name, step|
    cmd = UI::Command.new('cmd'){
      settings.update_timestep = step
    }
    cmd.menu_text = cmd.tooltip = name
    cmd.status_bar_text = "Update step - 1/#{(1/step).round} seconds. Smaller update step yields better accuracy."
    cmd.set_validation_proc {
      settings.update_timestep == step ? MF_CHECKED : MF_UNCHECKED
    }
    speed_menu.add_item(cmd)
  }


  sim_menu.add_separator

  debug_menu = sim_menu.add_submenu('Debug')


  cmd = UI::Command.new('cmd'){
    settings.collision_visible = !settings.collision_visible?
  }
  cmd.menu_text = cmd.tooltip = 'Collision Wireframe'
  cmd.status_bar_text = "Show/Hide body collision wireframe."
  cmd.set_validation_proc {
    settings.collision_visible? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/collision wireframe.png'
  cmd.large_icon = 'images/large/collision wireframe.png'
  toolbar.add_item(cmd)
  debug_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    settings.axis_visible = !settings.axis_visible?
  }
  cmd.menu_text = cmd.tooltip = 'Centre of Mass'
  cmd.status_bar_text = "Show/Hide body centre of mass axis."
  cmd.set_validation_proc {
    settings.axis_visible? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/centre of mass.png'
  cmd.large_icon = 'images/large/centre of mass.png'
  toolbar.add_item(cmd)
  debug_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    settings.bounding_box_visible = !settings.bounding_box_visible?
  }
  cmd.menu_text = cmd.tooltip = 'Bounding Box'
  cmd.status_bar_text = "Show/Hide body world axis aligned bounding box (AABB)."
  cmd.set_validation_proc {
    settings.bounding_box_visible? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/bounding box.png'
  cmd.large_icon = 'images/large/bounding box.png'
  toolbar.add_item(cmd)
  debug_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    settings.contact_points_visible = !settings.contact_points_visible?
  }
  cmd.menu_text = cmd.tooltip = 'Contact Points'
  cmd.status_bar_text = 'Show/Hide body contact points.'
  cmd.set_validation_proc {
    settings.contact_points_visible? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/contact points.png'
  cmd.large_icon = 'images/large/contact points.png'
  toolbar.add_item(cmd)
  debug_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    settings.contact_forces_visible = !settings.contact_forces_visible?
  }
  cmd.menu_text = cmd.tooltip = 'Contact Forces'
  cmd.status_bar_text = 'Show/Hide body contact forces.'
  cmd.set_validation_proc {
    settings.contact_forces_visible? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/contact force.png'
  cmd.large_icon = 'images/large/contact force.png'
  toolbar.add_item(cmd)
  debug_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    settings.bodies_visible = !settings.bodies_visible?
  }
  cmd.menu_text = cmd.tooltip = 'Bodies'
  cmd.status_bar_text = 'Show/Hide all bodies.'
  cmd.set_validation_proc {
    settings.bodies_visible? ? MF_CHECKED : MF_UNCHECKED
  }
  cmd.small_icon = 'images/small/bodies.png'
  cmd.large_icon = 'images/large/bodies.png'
  toolbar.add_item(cmd)
  debug_menu.add_item(cmd)


  cmd = UI::Command.new('cmd'){
    msg = "This option removes all MSPhysics assigned properties and scripts.\n"
    msg << 'Do you want to proceed?'
    choice = UI.messagebox(msg, MB_YESNO)
    MSPhysics.delete_all_attributes if choice == IDYES
  }
  cmd.menu_text = cmd.tooltip = 'Delete All Attributes'
  cmd.status_bar_text = 'Remove MSPhysics assigned properties and scripts from all entities.'
  plugin_menu.add_item(cmd)


  toolbar.show


  plugin_menu.add_separator

  about_msg = "MSPhysics #{MSPhysics::VERSION}, #{MSPhysics::RELEASE_DATE}\n"
  about_msg << "Powered by the Newton Dynamics #{MSPhysics.get_newton_version} physics SDK.\n"
  about_msg << "Copyright MIT © 2014, Anton Synytsia\n"
  about_msg << "Use SketchUcation PluginStore to check for updates."

  plugin_menu.add_item('About'){ UI.messagebox(about_msg) }


  MSPhysics::Joint::TYPES.each { |type|
    name = type.to_s
    words = name.split('_')
    for i in 0...words.size
      words[i].capitalize!
    end
    name1 = words.join(' ')
    name2 = name1.downcase
    cmd = UI::Command.new('cmd'){
      MSPhysics::JointTool.new(type)
    }
    cmd.menu_text = cmd.tooltip = name1
    cmd.status_bar_text = "Add #{name2} joint."
    cmd.small_icon = "images/small/#{name2}.png"
    cmd.large_icon = "images/large/#{name2}.png"
    joints_toolbar.add_item(cmd)
  }


  joints_toolbar.show


  UI.add_context_menu_handler { |menu|
    model = Sketchup.active_model
    ents = model.selection.to_a
    active = Sketchup.version.to_i > 6 ? model.active_path : nil
    parent = nil
    if active.is_a?(Array)
      next if active.size > 1
      parent = active[0]
      shape = MSPhysics.get_attribute(parent, 'MSPhysics Body', 'Shape')
      next if shape != 'Compound'
    end
    # Filter entities
    bodies = []
    joints = []
    ents.each { |ent|
      next unless [Sketchup::Group, Sketchup::ComponentInstance].include?(ent.class)
      type = MSPhysics.get_entity_type(ent)
      if type == 'Body'
        bodies << ent
      elsif type == 'Joint'
        joints << ent
      end
    }

    next if bodies.empty? and joints.empty?

    msp_menu = menu.add_submenu('MSPhysics')

    unless bodies.empty?
      state_menu = msp_menu.add_submenu('State')
      shape_menu = msp_menu.add_submenu('Shape')
      mat_menu = msp_menu.add_submenu('Material') unless parent

      options = ['Ignore', 'Not Collidable']
      options.concat ['Static', 'Frozen', 'Magnetic'] unless parent
      options.each { |option|
        item = state_menu.add_item(option){
          state = MSPhysics.get_attribute(bodies, 'MSPhysics Body', option) ? true : false
          MSPhysics.set_attribute(bodies, 'MSPhysics Body', option, !state)
          MSPhysics::Dialog.update_state
        }
        state_menu.set_validation_proc(item){
          MSPhysics.get_attribute(bodies, 'MSPhysics Body', option) ? MF_CHECKED : MF_UNCHECKED
        }
      }

      default_shape = MSPhysics::DEFAULT_BODY_SETTINGS[:shape]
      MSPhysics::Collision::SHAPES.each { |shape|
        words = shape.to_s.split('_')
        for i in 0...words.size
          words[i].capitalize!
        end
        option = words.join(' ')
        if parent
          next if ['Null', 'Compound', 'Compound From Mesh', 'Static Mesh'].include?(option)
        end
        item = shape_menu.add_item(option){
          MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Shape', option)
          MSPhysics::Dialog.update_state
        }
        shape_menu.set_validation_proc(item){
          MSPhysics.get_attribute(bodies, 'MSPhysics Body', 'Shape', default_shape) == option ? MF_CHECKED : MF_UNCHECKED
        }
      }

      unless parent
        default_mat = MSPhysics::DEFAULT_BODY_SETTINGS[:material_name]
        names = [default_mat, 'Custom'] + MSPhysics::Materials.get_names
        count = 0
        names.each { |name|
          item = mat_menu.add_item(name){
            if name == default_mat
              ['Material', 'Density', 'Static Friction', 'Dynamic Friction', 'Enable Friction', 'Elasticity', 'Softness'].each { |option|
                MSPhysics.delete_attribute(bodies, 'MSPhysics Body', option)
              }
            elsif name == 'Custom'
              MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Material', 'Custom')
            else
              MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Material', name)
              mat = MSPhysics::Materials.get_by_name(name)
              if mat
                MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Density', mat.density)
                MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Static Friction', mat.static_friction)
                MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Dynamic Friction', mat.dynamic_friction)
                MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Enable Friction', true)
                MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Elasticity', mat.elasticity)
                MSPhysics.set_attribute(bodies, 'MSPhysics Body', 'Softness', mat.softness)
              end
            end
            MSPhysics::Dialog.update_state
          }
          mat_menu.set_validation_proc(item){
            MSPhysics.get_attribute(bodies, 'MSPhysics Body', 'Material', default_mat) == name ? MF_CHECKED : MF_UNCHECKED
          }
          mat_menu.add_separator if count == 1
          count += 1
        }
      end
    end

    msp_menu.add_item('Delete Attributes'){
      msg = "This option removes MSPhysics assigned properties and scripts from the selected entities.\n"
      msg << 'Are you sure you want to proceed?'
      choice = UI.messagebox(msg, MB_YESNO)
      MSPhysics.delete_attributes(bodies) if choice == IDYES
    }
  }

  file_loaded(__FILE__)
end
