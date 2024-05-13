import sdformat14 as sdf

root = sdf.Root()
root.load("sphere2.sdf")

for world_index in range(root.world_count()):
    world = root.world_by_index(world_index)
    print(world.name())
    for model_index in range(world.model_count()):
        model = world.model_by_index(model_index)
        print("\tModel: ", model.name())
        for link_index in range(model.link_count()):
            link = model.link_by_index(link_index)
            print("\t\tLink: ", link.name())
            for collision_index in range(link.collision_count()):
                collision = link.collision_by_index(collision_index)
                print("\t\t\tCollision: ", collision.name())
                for visual_index in range(link.collision_count()):
                    visual = link.visual_by_index(visual_index)
                    print("\t\t\tVisual: ", visual.name())
