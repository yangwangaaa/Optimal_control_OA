%% Discretization size and problem setting
nx=100; % discretization size x axis
ny=100; % y axis
Lx=1;   % size of the domain x axis
Ly=1;   % y axis
smoothing_boundary = false; % deforms grid to be smoother around the boundary
                          % this makes neumann boundary conditions much
                          % more precise

% setting for the problem with solution: u(x,y)= x*x+y*y (dirichlet match
% the solution), therefore for low beta it match with Prescribed DB

f=@(x)x(:,1)*0+1;            % rhs of PDE
Neumann_boundary=@(x)x(:,1)*0;       % neuman boundary conditions (g(x))
Dirichlet_boundary=@(x)x(:,1)*0; % Dirichlet boundary to match
% Given neumann is on top,left and bottom side
% Given Dirichlet to optimize is on the left side (0.2,0.8) part of side
b_Dir={4,[0 1]};
b_Neu_known={3,[0 1]
    4,[0 1]
    1,[0 1]
    2,[0 0.15]
    2,[0.85 1]};
b_Neu_unknown={2,[0.15 0.85]};

% other parameters
sigma=1;
beta=1e-1;

%% Assemble all matrices and vector of the problem
[M_r,M_m,K,R_r,R_m,R_b,f_vec,g_vec,~,tri_grid] = assemblers.Assembly_all(nx,ny,Lx,Ly,...
    f,Neumann_boundary,Dirichlet_boundary,sigma,b_Dir,b_Neu_known,b_Neu_unknown,smoothing_boundary);


%% add artificially computed u_d
u_d = compute_artificial_u_d (nx,ny,smoothing_boundary);

%% Assembling 3x3 block matrix
n_u=length(tri_grid.node);
n_v=size(R_m,1);

M_r_pruh=R_r'*M_r*R_r;
N=R_m'*M_m;

A_3x3= [M_r_pruh            K             sparse(n_u,n_v)
        K              sparse(n_u,n_u)   -N
        sparse(n_v,n_u)    -N'            beta*M_m];
b_3x3=[R_r'*M_r*u_d
    f_vec+R_b'*g_vec
    sparse(n_v,1)];

% solution
res=A_3x3\b_3x3;

%%  extracting variables
u=res(1:n_u);
w=res((n_u+1):2*n_u);
v=res((2*n_u+1):end);

%% plotting results
plotting.plot_res(u,tri_grid); % values of u
plotting.plot_res_grad(u,tri_grid); % gradient of u
plotting.plot_Dir_bound(tri_grid,u,u_d,R_r); % difference on Dir. Boundary