#ifndef TRAJECTORY_DRAWER_H_
#define TRAJECTORY_DRAWER_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct trajectory_drawer trajectory_drawer;

trajectory_drawer* create_trajectory_drawer(double r, double g, double b);
void destroy_trajectory_drawer(trajectory_drawer* t_drawer);
void add_trajectory_message(trajectory_drawer* t_drawer, carmen_navigator_ackerman_plan_message *message);
void add_goal_list_message(trajectory_drawer* t_drawer, carmen_behavior_selector_goal_list_message *goals);
void draw_trajectory(trajectory_drawer* t_drawer, carmen_vector_3D_t offset);

#ifdef __cplusplus
}
#endif

#endif
