require 'csv'
require 'jekyll'

module Jekyll
  class CsvGenerator < Generator
    safe true

    def generate(site)
      # Path to the CSV files
      puts "CheckPlugin is running!"
      csv_folder = File.join(site.source, '_data', 'Final Round')

      # Iterate through each CSV file in the folder
      Dir.glob("#{csv_folder}/*.csv").each do |csv_file|
        # Read the CSV file
        csv_data = CSV.read(csv_file, headers: true)

        # Get the filename without extension for the page title and URL
        filename = File.basename(csv_file, '.csv')

        # Create a new page
        page = Page.new(site, site.source, File.join('csv', "#{filename}.html"), "#{filename}.html")

        # Set page attributes
        page.data['layout'] = 'csv'
        page.data['title'] = filename.split('_').map(&:capitalize).join(' ')
        page.data['csv_data'] = csv_data

        # Add the page to the site
        site.pages << page
      end
    end
  end
end
