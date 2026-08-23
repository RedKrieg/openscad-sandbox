total_length=float(input("Length of strut: "))
tensed_elastic_length_factor=0.62
ideal_tension_factor=0.5846153846153846
ends_addition=20

print(f"Cut elastic to {total_length*tensed_elastic_length_factor*ideal_tension_factor+ends_addition:.2f}mm assuming knots lose {ends_addition/2:.2f}mm of length.")
