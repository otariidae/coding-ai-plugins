class Api::RecipesController < Api::ApplicationController
  before_action :set_recipe, only: %i[ show update ]

  def index
    recipes = Current.user.recipes.published.includes(:author)

    render json: recipes.map { |recipe|
      {
        id: recipe.id,
        title: recipe.title,
        cooking_time: recipe.cooking_time,
        author_name: recipe.author.name,
        published_at: recipe.published_at,
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    }
  end

  def show
    render json: {
      id: @recipe.id,
      title: @recipe.title,
      body: @recipe.body.to_s,
      cooking_time: @recipe.cooking_time,
      servings: @recipe.servings,
      author_name: @recipe.author.name,
      author_avatar: @recipe.author.avatar_url,
      published_at: @recipe.published_at,
      steps: @recipe.steps.map { |step| { id: step.id, body: step.body } },
    }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def update
    @recipe.update! recipe_params

    render json: { id: @recipe.id, title: @recipe.title, updatedAt: @recipe.updated_at }
  end

  private
    def set_recipe
      @recipe = Current.user.recipes.find(params[:id])
    end

    def recipe_params
      params.expect(recipe: [ :title, :body, :cooking_time, :servings ])
    end
end
