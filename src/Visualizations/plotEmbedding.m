function plotEmbedding(x, f, energy)
figure;
colormap jet
p=patch('Faces', f, 'Vertices', [x, energy], 'FaceVertexCData', energy, 'EdgeColor','interp','FaceColor','interp');
grid on;
box on;
xlabel('$x_{m,1}$','interpreter','latex','FontSize',22);
ylabel('$x_{m,2}$','interpreter','latex','FontSize',22);
set(gca,'FontSize',18);
h = colorbar;
ylabel(h, 'pseudo-energy');
end
